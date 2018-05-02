//
//  DummyTest.swift
//  FirebaseRealtimePackageTests
//
//  Created by Austin Astorga on 5/2/18.
//

import Foundation
import Vapor
import FirebaseRealtime
import XCTest

struct User3 {
    var name: String
}

final class DummyTest: XCTestCase {
    var app: Application!

    static let allTests = [
    ("dummyTest", dummyTest)]

    override func setUp() {
        super.setUp()
       app = CreateApp.makeApp()
    }

    func dummyTest() throws {
        let client = try app.make(FirebaseClient.self)
        let response: [User3] = client.firebaseRoutes.retrieveMany(req: app, appendedPath: [.child("users"), .json]).wait()

    }
}
