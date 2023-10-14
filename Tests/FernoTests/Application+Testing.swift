//
//  Application+Testing.swift
//  Async
//
//  Created by Austin Astorga on 5/1/18.
//

import Ferno
import XCTVapor

func defaultLaunch(_ test: (Application) async throws -> Void) async throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    app.ferno.use(
        .default(
            FernoConfiguration(
                basePath: "database-url",
                email: "service-account-email",
                privateKey: "private-key"
            )
        )
    )
    try await test(app)
}

func serviceJsonLaunch(_ test: (Application) async throws -> Void) async throws {
    let app = Application(.testing)
    guard let json = FirebaseAccountKey.json.data(using: .utf8) else { return }
    
    let configuration = try FernoServiceJsonConfiguration(json: json)
    defer { app.shutdown() }
    app.ferno.use(
        .serviceAccountKey(configuration)
    )
    try await test(app)
}
