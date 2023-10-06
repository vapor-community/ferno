//
//  FernoConfiguration.swift
//  Ferno
//
//  Created by Maxim Krouk on 6/12/20.
//

import Vapor

public struct FernoConfiguration {
    public let logger: Logger
    public let basePath: String
    public let email: String
    public let privateKey: String
    public var accessToken: String?
    public var tokenExpirationDate: Date?

    public init(
        basePath: String,
        email: String,
        privateKey: String,
        accessToken: String? = nil,
        tokenExpirationDate: Date? = nil,
        logger: Logger = .init(label: "codes.vapor.ferno")
    ) {
        self.basePath = basePath
        self.email = email
        self.privateKey = privateKey
        self.accessToken = accessToken
        self.tokenExpirationDate = tokenExpirationDate
        self.logger = logger
    }
}
