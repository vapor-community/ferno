//
//  Provider.swift
//  FirebaseRealtime
//
//  Created by Austin Astorga on 4/30/18.
//

import Vapor
import JWT

struct Payload: JWTPayload {
    
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
    
    var iss: IssuerClaim
    var scope: String
    var aud: String
    var exp: ExpirationClaim
    var iat: IssuedAtClaim
}

public struct AccessToken {
    var accessToken: String
    var email: String
    var privateKey: String
    var jwt: JWT<Payload>
}

public struct FernoConfig: Service {
    public let basePath: String
    public let email: String
    public let privateKey: String

    public init(basePath: String, email: String, privateKey: String) {
        self.basePath = basePath
        self.email = email
        self.privateKey = privateKey
    }
}

public final class FernoProvider: Provider {

    public init() { }

    public func register(_ services: inout Services) throws {
        services.register { container -> FernoClient in
            let httpClient = try container.make(Client.self)
            let config = try container.make(FernoConfig.self)
            return FernoClient(client: httpClient, basePath: config.basePath, email: config.email, privateKey: config.privateKey)

        }
    }

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return EventLoopFuture.done(on: container)
    }


}

public struct FernoClient: Service {
    public var ferno: FernoRoutes

    internal init(client: Client, basePath: String, email: String, privateKey: String) {
        let apiRequest = FernoAPIRequest(httpClient: client, basePath: basePath, email: email, privateKey: privateKey)

        ferno = FernoRoutes(request: apiRequest)

    }
}
