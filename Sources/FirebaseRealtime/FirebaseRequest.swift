import Vapor

public protocol FirebaseRequest {
    func send<F: Content>(req: Request,method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<F>
}

public class FirebaseAPIRequest: FirebaseRequest {

    private let decoder = JSONDecoder()
    private let httpClient: Client
    private let authKey: String
    private let basePath: String

    public init(httpClient: Client, authKey: String, basePath: String) {
        self.httpClient = httpClient
        self.authKey = authKey
        self.basePath = basePath
    }

    public func send<F: Content>(req: Request, method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<F> {
        let request = self.createRequest(method: method, path: path, query: query, body: body, headers: headers)
        return try self.httpClient.respond(to: request).flatMap(to: F.self) { response in
            guard response.http.status == .ok else { throw FirebaseRealtimeError.requestFailed }
            return try self.decoder.decode(F.self, from: response.http, maxSize: 65_536, on: req)
        }
    }

    public func send<F: Content>(req: Request, method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) throws -> Future<[F]> {
        let request = self.createRequest(method: method, path: path, query: query, body: body, headers: headers)
        return try self.httpClient.respond(to: request).flatMap(to: [F].self) { response in
            guard response.http.status == .ok else { throw FirebaseRealtimeError.requestFailed }
            return try self.decoder.decode([String : F].self, from: response.http, maxSize: 65_536, on: req).map(to: [F].self) { data in
                return Array(data.values)
            }
        }
    }
}

extension FirebaseAPIRequest {
    private func createRequest(method: HTTPMethod, path: [FirebasePath], query: [FirebaseQueryParams], body: String, headers: HTTPHeaders) -> Request {
        let encodedHTTPBody = HTTPBody(string: body)
        let completePath = basePath + path.childPath
        let queryString = query.createQuery(authKey: self.authKey)
        let urlString = "\(completePath)?\(queryString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let request = HTTPRequest(method: method, url: urlString, headers: headers, body: encodedHTTPBody)
        return Request(http: request, using: self.httpClient.container)
    }
}
