//
//  Application+Testing.swift
//  Async
//
//  Created by Austin Astorga on 5/1/18.
//

import Foundation
import FirebaseRealtime
import Vapor

class CreateApp {
    static func makeApp() -> Application {
        let config = Config.default()
        let env = try! Environment.detect()
        var services = Services.default()
        let firebaseConfig = FirebaseConfig(authKey: "t97WupTaor205BJUdD7ewkEHx8S54rnpjW0VBZpD", basePath: "https://brella-f32d9.firebaseio.com")
        services.register(firebaseConfig)
        try! services.register(FirebaseProvider())


        return try! Application(config: config, environment: env, services: services)
    }
}
