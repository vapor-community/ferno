//
//  Provider.swift
//  FirebaseRealtime
//
//  Created by Austin Astorga on 4/30/18.
//

import Vapor

public struct FirebaseConfig: Service {
    public let authKey: String
    public let basePath: String

    public init(authKey: String, basePath: String) {
        self.authKey = authKey
        self.basePath = basePath

    }
}

public final class FirebaseProvider: Provider {

    public func register(_ services: inout Services) throws {
        services.register { container -> FirebaseClient in
            let httpClient = try container.make(Client.self)
            let config = try container.make(FirebaseConfig.self)
            return FirebaseClient(authKey: config.authKey, client: httpClient, basePath: config.basePath)

        }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return EventLoopFuture.done(on: container)
    }


}

public struct FirebaseClient: Service {
    public var firebaseRoutes: FirebaseRoutes

    internal init(authKey: String, client: Client, basePath: String) {
        let apiRequest = FirebaseAPIRequest(httpClient: client, authKey: authKey, basePath: basePath)

        firebaseRoutes = FirebaseRoutes(request: apiRequest)

    }
}
