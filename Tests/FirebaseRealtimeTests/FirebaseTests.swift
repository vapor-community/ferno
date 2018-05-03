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

struct Teacher: Content {
    var name: String
    var teachesGrade: String
    var age: Int
}

struct UpdateStudentInfo: Content {
    var major: String
}

struct Student: Content {
    var name: String
    var major: String
    var school: String
    var age: Int
    var willGraduate: Bool
}

final class FirebaseTests: XCTestCase {
    
    var app: Application!

    static let allTests = [
        ("testGetStudents", testGetStudents),
        ("testCreateStudent", testCreateStudent)
    ]

    override func setUp() {
        super.setUp()
        self.app = CreateApp.makeApp()
    }

    //GET students
    func testGetStudents() throws {
        do {
            let names = ["Austin", "Ashley", "Billy"]
            let ages = ["Austin": 21, "Ashley": 20, "Billy": 22]
            let majors = ["Austin": "Computer Science", "Ashley": "Biology", "Billy": "Business"]
            let schools = ["Austin": "Cornell University", "Ashley": "Siena & Cornell University", "Billy": "Mira Costa Community"]
            let willGradaute = ["Austin": true, "Ashley": true, "Billy": false]

            let client = try self.app.make(FirebaseClient.self)
            let request = Request(using: self.app)
            let students: [Student] = try client.firebaseRoutes.retrieveMany(req: request, appendedPath: [.json]).wait()

            XCTAssertNotNil(students)

            XCTAssert(students.count == 3, "Making sure all 3 students are returned")
            students.forEach { student in
                XCTAssert(names.contains(student.name), "Checking name for \(student.name)")
                XCTAssert(ages[student.name] == student.age, "Checking age for \(student.name)")
                XCTAssert(majors[student.name] == student.major, "Checking major for \(student.name)")
                XCTAssert(schools[student.name] == student.school, "Checking school for \(student.name)")
                XCTAssert(willGradaute[student.name] == student.willGraduate, "Checking willGraduate for \(student.name)")
            }
        } catch {
            print(error)
        }
    }

    //POST Student
    func testCreateStudent() throws {
        do {
            let student = Student(name: "Matt", major: "Computer Science", school: "Cornell University", age: 20, willGraduate: true)
            let client = try self.app.make(FirebaseClient.self)
            let request = Request(using: self.app)
            let child = try client.firebaseRoutes.create(req: request, appendedPath: [.json], body: student).wait()
            XCTAssertNotNil(child.name)
        } catch {
            print(error)
            XCTFail()
        }
    }

    //DELETE student
    func testDeleteStudent() throws {
        do {
            let client = try self.app.make(FirebaseClient.self)
            let request = Request(using: self.app)
            let success = try client.firebaseRoutes.delete(req: request, appendedPath: [.child("User1"), .json]).wait()
            XCTAssertTrue(success, "did delete child")
        } catch {
            print(error)
            XCTFail()
        }
    }

    //PATCH update student
    func testUpdateStudent() throws {
        do {
            let client = try self.app.make(FirebaseClient.self)
            let request = Request(using: self.app)
            let updateStudentInfo = UpdateStudentInfo(major: "Cooking")
            let response = try client.firebaseRoutes.update(req: request, appendedPath: [.child("User2"), .json], body: updateStudentInfo).wait()
            XCTAssertTrue(response.major == updateStudentInfo.major)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    //PUT overwrite student
    func testOverwriteStudent() throws {
        do {
            let teacher = Teacher(name: "Ms. Jennifer", teachesGrade: "12th", age: 29)
            let client = try self.app.make(FirebaseClient.self)
            let request = Request(using: self.app)
            let response: Teacher = try client.firebaseRoutes.overwrite(req: request, appendedPath: [.child("User3"), .json], body: teacher).wait()
            XCTAssertTrue(response.name == teacher.name)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
