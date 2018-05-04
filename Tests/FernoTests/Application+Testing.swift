//
//  Application+Testing.swift
//  Async
//
//  Created by Austin Astorga on 5/1/18.
//

import Foundation
import Ferno
import Vapor

class CreateApp {
    static func makeApp() -> Application {
        let privateKey = """
"""

        let config = Config.default()
        let env = try! Environment.detect()
        var services = Services.default()
        let firebaseConfig = FernoConfig(basePath: "", email: "", privateKey: privateKey)
        services.register(firebaseConfig)
        try! services.register(FernoProvider())


        return try! Application(config: config, environment: env, services: services)
    }
}
