//
//  DummyTest.swift
//  FirebaseRealtimePackageTests
//
//  Created by Austin Astorga on 5/2/18.
//

import Foundation
import Vapor
import Ferno
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

    //GET a student
    func testGetStudent() throws {
        do {
            let client = try self.app.make(FernoClient.self)
            let request = Request(using: self.app)

            //Create 3 new students
            let austin = Student(name: "Austin", major: "Computer Science", school: "Cornell University", age: 21, willGraduate: true)
             let child = try client.ferno.create(req: request, appendedPath: ["Student-get"], body: austin).wait()

            let student: Student = try client.ferno.retrieve(req: request, queryItems: [], appendedPath: ["Student-get", child.name]).wait()

            XCTAssert(student.name == "Austin")
            XCTAssert(student.major == "Computer Science")

            let success = try client.ferno.delete(req: request, appendedPath: ["Student-get", child.name]).wait()

            XCTAssertTrue(success)

        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    //GET students
    func testGetStudents() throws {
        do {
            let client = try self.app.make(FernoClient.self)
            let request = Request(using: self.app)

            //Create 3 new students
            let austin = Student(name: "Austin", major: "Computer Science", school: "Cornell University", age: 21, willGraduate: true)
            let ashley = Student(name: "Ashley", major: "Biology", school: "Siena & Cornell University", age: 20, willGraduate: true)
            let billy = Student(name: "Billy", major: "Business", school: "Mira Costa Community", age: 22, willGraduate: false)

            let _ = try client.ferno.create(req: request, appendedPath: ["Students-get"], body: austin).wait()
           let _ = try client.ferno.create(req: request, appendedPath: ["Students-get"], body: ashley).wait()
           let _ = try client.ferno.create(req: request, appendedPath: ["Students-get"], body: billy).wait()


            let names = ["Austin", "Ashley", "Billy"]
            let ages = ["Austin": 21, "Ashley": 20, "Billy": 22]
            let majors = ["Austin": "Computer Science", "Ashley": "Biology", "Billy": "Business"]
            let schools = ["Austin": "Cornell University", "Ashley": "Siena & Cornell University", "Billy": "Mira Costa Community"]
            let willGradaute = ["Austin": true, "Ashley": true, "Billy": false]


            let students: [Student] = try client.ferno.retrieveMany(req: request, queryItems: [], appendedPath: ["Students-get"]).wait().map { $0.value }

            XCTAssertNotNil(students)

            XCTAssert(students.count == 3, "Making sure all 3 students are returned")
            students.forEach { student in
                XCTAssert(names.contains(student.name), "Checking name for \(student.name)")
                XCTAssert(ages[student.name] == student.age, "Checking age for \(student.name)")
                XCTAssert(majors[student.name] == student.major, "Checking major for \(student.name)")
                XCTAssert(schools[student.name] == student.school, "Checking school for \(student.name)")
                XCTAssert(willGradaute[student.name] == student.willGraduate, "Checking willGraduate for \(student.name)")
            }

            let success = try client.ferno.delete(req: request, appendedPath: ["Students-get"]).wait()

            XCTAssertTrue(success)

        } catch {
            print(error)
        }
    }

    //POST Student
    func testCreateStudent() throws {
        do {
            let student = Student(name: "Matt", major: "Computer Science", school: "Cornell University", age: 20, willGraduate: true)
            let client = try self.app.make(FernoClient.self)
            let request = Request(using: self.app)
            let child = try client.ferno.create(req: request, appendedPath: [], body: student).wait()
            XCTAssertNotNil(child.name)

            let success = try client.ferno.delete(req: request, appendedPath: [child.name]).wait()

            XCTAssertTrue(success)
        } catch {
            print(error)
            XCTFail()
        }
    }

    //DELETE student
    func testDeleteStudent() throws {
        do {
            let client = try self.app.make(FernoClient.self)
            let request = Request(using: self.app)
            let timothy = Student(name: "Timothy", major: "Agriculture", school: "Mira Costa Community", age: 24, willGraduate: false)

            let child = try client.ferno.create(req: request, appendedPath: ["Students-delete"], body: timothy).wait()


            let success = try client.ferno.delete(req: request, appendedPath: ["Students-delete", child.name]).wait()
            XCTAssertTrue(success, "did delete child")
        } catch {
            print(error)
            XCTFail()
        }
    }

    //PATCH update student
    func testUpdateStudent() throws {
        do {
            let client = try self.app.make(FernoClient.self)
            let request = Request(using: self.app)
            let austin = Student(name: "Austin", major: "Computer Science", school: "Cornell Univeristy", age: 21, willGraduate: true)
            let child = try client.ferno.create(req: request, appendedPath: ["Students-patch"], body: austin).wait()


            let updateStudentInfo = UpdateStudentInfo(major: "Cooking")
            let response = try client.ferno.update(req: request, appendedPath: ["Students-patch", child.name], body: updateStudentInfo).wait()
            XCTAssertTrue(response.major == updateStudentInfo.major)

            let success = try client.ferno.delete(req: request, appendedPath: ["Students-patch", child.name]).wait()

            XCTAssertTrue(success)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    //PUT overwrite student
    func testOverwriteStudent() throws {
        do {
            let client = try self.app.make(FernoClient.self)
            let request = Request(using: self.app)
            let austin = Student(name: "Austin", major: "Computer Science", school: "Cornell Univeristy", age: 21, willGraduate: true)
            let child = try client.ferno.create(req: request, appendedPath: ["Students-put"], body: austin).wait()



            let teacher = Teacher(name: "Ms. Jennifer", teachesGrade: "12th", age: 29)
            let response: Teacher = try client.ferno.overwrite(req: request, appendedPath: ["Students-put", child.name], body: teacher).wait()
            XCTAssertTrue(response.name == teacher.name)

            let success = try client.ferno.delete(req: request, appendedPath: ["Students-put", child.name]).wait()
            XCTAssertTrue(success)


        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
