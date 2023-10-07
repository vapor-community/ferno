//
//  FernoConfiguration.swift
//  Ferno
//
//  Created by Maxim Krouk on 6/12/20.
//

import Vapor

public protocol Configuration {
    var logger: Logger { get }
    var basePath: String { get }
    var email: String { get }
    var privateKey: String { get }
    var accessToken: String? { get set }
    var tokenExpriationDate: Date? { get set }
}

public struct FernoConfiguration: Configuration {
    public let logger: Logger
    public let basePath: String
    public let email: String
    public let privateKey: String
    public var accessToken: String?
    public var tokenExpriationDate: Date?

    public init(
        basePath: String,
        email: String,
        privateKey: String,
        accessToken: String? = nil,
        tokenExpriationDate: Date? = nil,
        logger: Logger = .init(label: "codes.vapor.ferno")
    ) {
        self.basePath = basePath
        self.email = email
        self.privateKey = privateKey
        self.accessToken = accessToken
        self.tokenExpriationDate = tokenExpriationDate
        self.logger = logger
    }
}
