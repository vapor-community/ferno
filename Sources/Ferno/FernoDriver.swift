//
//  FernoDriver.swift
//  Ferno
//
//  Created by Maxim Krouk on 6/12/20.
//

import Vapor

/// A new driver for Ferno
public protocol FernoDriver {
    /// Makes the ferno client
    func makeClient(with config: FernoConfigurationProvider) -> FernoClient

    /// Shuts down the driver
    func shutdown()
}

struct FernoDefaultDriver: FernoDriver {
    var client: Client
    func makeClient(with config: FernoConfigurationProvider) -> FernoClient { FernoAPIClient(configuration: config, client: client) }
    func shutdown() {}
}

struct FernoServiceAccountKeyDriver: FernoDriver {
    var client: Client
    func makeClient(with config: FernoConfigurationProvider) -> FernoClient { FernoAPIClient(configuration: config, client: client) }
    func shutdown() {}
}
