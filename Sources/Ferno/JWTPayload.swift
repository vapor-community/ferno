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
