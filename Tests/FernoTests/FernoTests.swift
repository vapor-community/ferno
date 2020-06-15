//
//  DummyTest.swift
//  FirebaseRealtimePackageTests
//
//  Created by Austin Astorga on 5/2/18.
//

import XCTVapor
import Ferno

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

    //GET a student
    func testGetStudent() throws {
        try launch { app in
            
            let request = Request(application: app, on: app.eventLoopGroup.next())
            //Create 3 new students
            let austin = Student(name: "Austin", major: "Computer Science", school: "Cornell University", age: 21, willGraduate: true)
            let child = try app.ferno.create(["Student-get"], body: austin, on: request).wait()

            let student: Student = try app.ferno.retrieve(["Student-get", child.name], queryItems: [], on: request).wait()

            XCTAssert(student.name == "Austin")
            XCTAssert(student.major == "Computer Science")

            let success = try app.ferno.delete(["Student-get", child.name], on: request).wait()

            XCTAssertTrue(success)
        }
    }

    //GET students
    func testGetStudents() throws {
        try launch { app in
            let request = Request(application: app, on: app.eventLoopGroup.next())

            //Create 3 new students
            let austin = Student(name: "Austin", major: "Computer Science", school: "Cornell University", age: 21, willGraduate: true)
            let ashley = Student(name: "Ashley", major: "Biology", school: "Siena & Cornell University", age: 20, willGraduate: true)
            let billy = Student(name: "Billy", major: "Business", school: "Mira Costa Community", age: 22, willGraduate: false)

            let _ = try app.ferno.create(["Students-get"], body: austin, on: request).wait()
            let _ = try app.ferno.create(["Students-get"], body: ashley, on: request).wait()
            let _ = try app.ferno.create(["Students-get"], body: billy, on: request).wait()


            let names = ["Austin", "Ashley", "Billy"]
            let ages = ["Austin": 21, "Ashley": 20, "Billy": 22]
            let majors = ["Austin": "Computer Science", "Ashley": "Biology", "Billy": "Business"]
            let schools = ["Austin": "Cornell University", "Ashley": "Siena & Cornell University", "Billy": "Mira Costa Community"]
            let willGradaute = ["Austin": true, "Ashley": true, "Billy": false]


            let students: [Student] = try app.ferno.retrieveMany("Students-get", queryItems: [], on: request).wait().map { $0.value }

            XCTAssertNotNil(students)

            XCTAssert(students.count == 3, "Making sure all 3 students are returned")
            students.forEach { student in
                XCTAssert(names.contains(student.name), "Checking name for \(student.name)")
                XCTAssert(ages[student.name] == student.age, "Checking age for \(student.name)")
                XCTAssert(majors[student.name] == student.major, "Checking major for \(student.name)")
                XCTAssert(schools[student.name] == student.school, "Checking school for \(student.name)")
                XCTAssert(willGradaute[student.name] == student.willGraduate, "Checking willGraduate for \(student.name)")
            }

            let success = try app.ferno.delete("Students-get", on: request).wait()

            XCTAssertTrue(success)

        }
    }

    //POST Student
    func testCreateStudent() throws {
        try launch { app in
            let request = Request(application: app, on: app.eventLoopGroup.next())
            let student = Student(name: "Matt", major: "Computer Science", school: "Cornell University", age: 20, willGraduate: true)
            let child = try app.ferno.create(body: student, on: request).wait()
            XCTAssertNotNil(child.name)

            let success = try app.ferno.delete(child.name, on: request).wait()

            XCTAssertTrue(success)
        }
    }

    //DELETE student
    func testDeleteStudent() throws {
        try launch { app in
            let request = Request(application: app, on: app.eventLoopGroup.next())
            let timothy = Student(name: "Timothy", major: "Agriculture", school: "Mira Costa Community", age: 24, willGraduate: false)

            let child = try app.ferno.create("Students-delete", body: timothy, on: request).wait()


            let success = try app.ferno.delete(["Students-delete", child.name], on: request).wait()
            XCTAssertTrue(success, "did delete child")
        }
    }

    //PATCH update student
    func testUpdateStudent() throws {
        try launch { app in
            let request = Request(application: app, on: app.eventLoopGroup.next())
            let austin = Student(name: "Austin", major: "Computer Science", school: "Cornell Univeristy", age: 21, willGraduate: true)
            let child = try app.ferno.create(["Students-patch"], body: austin, on: request).wait()


            let updateStudentInfo = UpdateStudentInfo(major: "Cooking")
            let response = try app.ferno.update(["Students-patch", child.name], body: updateStudentInfo, on: request).wait()
            XCTAssertTrue(response.major == updateStudentInfo.major)

            let success = try app.ferno.delete(["Students-patch", child.name], on: request).wait()

            XCTAssertTrue(success)
            
        }
    }

    //PUT overwrite student
    func testOverwriteStudent() throws {
        try launch { app in
            let request = Request(application: app, on: app.eventLoopGroup.next())
            let austin = Student(name: "Austin", major: "Computer Science", school: "Cornell Univeristy", age: 21, willGraduate: true)
            let child = try app.ferno.create(["Students-put"], body: austin, on: request).wait()



            let teacher = Teacher(name: "Ms. Jennifer", teachesGrade: "12th", age: 29)
            let response: Teacher = try app.ferno.overwrite(["Students-put", child.name], body: teacher, on: request).wait()
            XCTAssertTrue(response.name == teacher.name)

            let success = try app.ferno.delete(["Students-put", child.name], on: request).wait()
            XCTAssertTrue(success)


        }
    }
}
