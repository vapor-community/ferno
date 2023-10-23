//
//  FernoConfiguration.swift
//  Ferno
//
//  Created by Maxim Krouk on 6/12/20.
//

import Vapor

public protocol FernoConfigurationProvider {
    var logger: Logger { get }
    var basePath: String { get }
    var email: String { get }
    var privateKey: String { get }
    var accessToken: String? { get set }
    var tokenExpirationDate: Date? { get set }
    var tokenURI: String { get }
}

@available(*, deprecated, renamed: "FernoDefaultConfiguration")
public struct FernoConfiguration: FernoConfigurationProvider {
    public let logger: Logger
    public let basePath: String
    public let email: String
    public let privateKey: String
    public var accessToken: String?
    public var tokenExpirationDate: Date?
    public let tokenURI: String = "https://oauth2.googleapis.com/token"
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
        self.tokenExpirationDate = tokenExpriationDate
        self.logger = logger
    }
}

public struct FernoDefaultConfiguration: FernoConfigurationProvider {
    public let logger: Logger
    public let basePath: String
    public let email: String
    public let privateKey: String
    public var accessToken: String?
    public var tokenExpirationDate: Date?
    public let tokenURI: String = "https://oauth2.googleapis.com/token"
    
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
