import Vapor
import JWT
import NIOConcurrencyHelpers

struct OAuthBody: Content {
    var grantType: String
    var assertion: String

    private enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case assertion
    }
}

struct OAuthResponse: Content {
    var accessToken: String
    var tokenType: String
    var expiresIn: Int

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

public protocol FernoClient {
    func delete(
        method: HTTPMethod,
        path: [String]
    ) async throws -> Bool

    func send<F: Decodable, T: Content>(
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) async throws -> F

    func sendMany<F: Decodable, T: Content>(
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) async throws -> [String: F]
}

final class FernoAPIClient: FernoClient {
    private let decoder = JSONDecoder()
    private let client: Client
    private(set) public var configuration: FernoConfigurationProvider
    private let lock = NIOLock()

    public init(configuration: FernoConfigurationProvider, client: Client) {
        self.configuration = configuration
        self.client = client
    }

    public func delete(
        method: HTTPMethod,
        path: [String]
    ) async throws -> Bool {
        let req = try await self.createRequest(method: method, path: path, query: [], body: "", headers: [:])
        let response = try await client.send(req)
        return response.status == .ok
    }

    public func send<F: Decodable, T: Content>(
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) async throws -> F {
        let req = try await self.createRequest(method: method, path: path, query: query, body: body, headers: headers)
        let res = try await client.send(req)
        guard res.status == .ok else { throw FernoError.requestFailed }
        return try res.content.decode(F.self)
    }

    public func sendMany<F: Decodable, T: Content>(
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) async throws -> [String: F] {
        let req = try await self.createRequest(method: method, path: path, query: query, body: body, headers: headers)
        let res = try await self.client.send(req)
        guard res.status == .ok else { throw FernoError.requestFailed }
        return try res.content.decode(Snapshot<F>.self).data
    }
}

extension FernoAPIClient {
    private func createRequest<T: Content>(
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) async throws -> ClientRequest {
        let accessToken = try await getAccessToken()
        let fernoPath: [FernoPath] = path.makeFernoPath()
        let completePath = self.configuration.basePath + fernoPath.childPath
        let queryString = query.createQuery(authKey: accessToken)
        let urlString = completePath + queryString
        var request = ClientRequest(method: method, url: URI(string: urlString), headers: headers, body: nil)
        try request.content.encode(body)
        return request
    }

    private func createJWT() throws -> String {
        let privateSigner = try JWTSigner.rs256(key: .private(pem: self.configuration.privateKey.bytes))
        let currentDate = Date()
        let expirationDate = currentDate.addingTimeInterval(3600)
        let payload = Payload(
            iss: .init(value: self.configuration.email),
            scope: [
                "https://www.googleapis.com/auth/userinfo.email",
                "https://www.googleapis.com/auth/firebase.database"
            ].joined(separator: " "),
            aud: configuration.tokenURI,
            exp: .init(value: expirationDate),
            iat: .init(value: currentDate)
        )

        return try privateSigner.sign(payload)
    }

    private func getAccessToken() async throws -> String {

        if let cachedToken = lock.withLock({
            if let accessToken = configuration.accessToken,
               let tokenExpirationDate = configuration.tokenExpirationDate,
               Date().timeIntervalSince(tokenExpirationDate) > 30*60 { // should be valid for 1 hour
                return accessToken
            } else {
                return nil
            }
        }) {
            return cachedToken
        }

        configuration.logger.debug("Going to get accessToken")
        let jwt = try createJWT()
        configuration.logger.debug("JWT created")

        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/x-www-form-urlencoded")
        let oauthBody = OAuthBody(grantType: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion: jwt)
        var req = ClientRequest(
            method: .POST,
            url: URI(string: configuration.tokenURI),
            headers: headers,
            body: nil
        )
        try req.content.encode(oauthBody, as: .urlEncodedForm)

        let res = try await client.send(req).content.decode(OAuthResponse.self)
        lock.withLockVoid {
            self.configuration.accessToken = res.accessToken
            self.configuration.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(res.expiresIn))
        }
        self.configuration.logger.debug("Access token received")
        return res.accessToken
    }
}
