import Vapor
import JWT

struct OAuthBody: Content {
    var grant_type: String
    var assertion: String
}

struct OAuthResponse: Content {
    var access_token: String
    var token_type: String
    var expires_in: Int
}

public protocol FernoClient {
    func delete(
        on req: Request,
        method: HTTPMethod,
        path: [String]
    ) throws -> EventLoopFuture<Bool>
    
    func send<F: Decodable, T: Content>(
        on req: Request,
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) throws -> EventLoopFuture<F>
    
    func sendMany<F: Decodable, T: Content>(
        on req: Request,
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) throws -> EventLoopFuture<[String: F]>
}

final class FernoAPIClient: FernoClient {
    private let decoder = JSONDecoder()
    private let client: Client
    private(set) public var configuration: FernoConfiguration

    public init(configuration: FernoConfiguration, client: Client) {
        self.configuration = configuration
        self.client = client
    }

    public func delete(
        on req: Request,
        method: HTTPMethod,
        path: [String]
    ) throws -> EventLoopFuture<Bool> {
        try self.createRequest(method: method, path: path, query: [], body: "", headers: [:]).flatMap { req in
            self.client.send(req).map { $0.status == .ok }
        }
    }

    public func send<F: Decodable, T: Content>(
        on req: Request,
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) throws -> EventLoopFuture<F> {
        try self.createRequest(method: method, path: path, query: query, body: body, headers: headers).flatMap { req in
            self.client.send(req).flatMapThrowing { res in
                guard res.status == .ok else { throw FernoError.requestFailed }
                return try res.content.decode(F.self)
            }
        }
    }

    public func sendMany<F: Decodable, T: Content>(
        on req: Request,
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) throws -> EventLoopFuture<[String: F]> {
        try self.createRequest(method: method, path: path, query: query, body: body, headers: headers).flatMap { req in
            self.client.send(req).flatMapThrowing { res in
                guard res.status == .ok else { throw FernoError.requestFailed }
                return try res.content.decode(Snapshot<F>.self).data
            }
        }
    }
}

extension FernoAPIClient {
    private func createRequest<T: Content>(
        method: HTTPMethod,
        path: [String],
        query: [FernoQuery],
        body: T,
        headers: HTTPHeaders
    ) throws -> EventLoopFuture<ClientRequest> {
        try getAccessToken().flatMapThrowing { accessToken in
            let fernoPath: [FernoPath] = path.makeFernoPath()
            let completePath = self.configuration.basePath + fernoPath.childPath
            let queryString = query.createQuery(authKey: accessToken)
            let urlString = completePath + queryString
            var request = ClientRequest(method: method, url: URI(string: urlString), headers: headers, body: nil)
            try request.content.encode(body)
            return request
        }
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
            aud: "https://www.googleapis.com/oauth2/v4/token",
            exp: .init(value: expirationDate),
            iat: .init(value: currentDate)
        )
        self.configuration.tokenExpriationDate = expirationDate
        
        return try privateSigner.sign(payload)
    }

    private func getAccessToken() throws -> EventLoopFuture<String> {
        //if let expireDate = self.expireDate,  Calendar.current.compare(expireDate, to: Date(timeIntervalSinceNow: -120), toGranularity: .second) == .orderedDescending {
        //    guard let accessToken = self.accessToken else { throw FernoError.invalidAccessToken }
        //    return EventLoopFuture.map(on: self.httpClient.container) { accessToken }
        //}
        //we need to refresh the token
        configuration.logger.debug("Going to get accessToken")
        let jwt = try createJWT()
        configuration.logger.debug("JWT created")
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/x-www-form-urlencoded")
        let oauthBody = OAuthBody(grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion: jwt)
        var req = ClientRequest(
            method: .POST,
            url: URI(string: "https://www.googleapis.com/oauth2/v4/token"),
            headers: headers,
            body: nil
        )
        try req.content.encode(oauthBody, as: .urlEncodedForm)

        return self.client.send(req)
            .flatMapThrowing { try $0.content.decode(OAuthResponse.self) }
            .map { res in
                self.configuration.accessToken = res.access_token
                self.configuration.logger.debug("Access token received")
                return res.access_token
        }
    }
}
