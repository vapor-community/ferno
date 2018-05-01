import Foundation
import HTTP
import Service

class Firebase: Service {
    var authKey: String
    var basePath: String

    private var urlBuilder: URLComponents?


    init(authKey: String, basePath: String) {
        self.authKey = authKey
        self.basePath = basePath
        self.urlBuilder = URLComponents(string: basePath)
    }

    open func get(path: String, worker: Worker) throws -> Future<Data> {
        var queryItems: [URLQueryItem] = []
        let authQuery = URLQueryItem(name: "auth", value: self.authKey)
        queryItems.append(authQuery)

        let path = basePath + path
        guard var urlBuilder = URLComponents(string: path) else { throw FirebaseRealtimeError.invalidURL }
        urlBuilder.queryItems = queryItems

        guard let fullURL = urlBuilder.url, let hostname = urlBuilder.host else { throw FirebaseRealtimeError.invalidURL }


        let data: Future<Data> = HTTPClient.connect(scheme: .https, hostname: hostname, on: worker)
            .flatMap(to: HTTPResponse.self) { client in
                print(fullURL.description)
                let httpRequest = HTTPRequest(method: .GET, url: fullURL)
                return client.send(httpRequest)
            }.flatMap(to: Data.self) { response in
                if response.status != .ok { throw FirebaseRealtimeError.requestFailed }
                return response.body.consumeData(on: worker)
        }

        return data
    }
}
