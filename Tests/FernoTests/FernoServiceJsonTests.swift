import XCTVapor
import Ferno

class FernoServiceJsonTests: XCTestCase {
    // GET a student
    func testGetStudent() async throws {
        try await serviceJsonLaunch { app in
            // Create 3 new students
            let austin = Student(name: "Austin", major: "Computer Science",
                                          school: "Cornell University", age: 21, willGraduate: true)
            let child = try await app.ferno.create(["Student-get"], body: austin)

            let student: Student = try await app.ferno.retrieve(["Student-get", child.name], queryItems: [])

            XCTAssert(student.name == "Austin")
            XCTAssert(student.major == "Computer Science")

            let success = try await app.ferno.delete(["Student-get", child.name])

            XCTAssertTrue(success)
        }
    }

    // GET students
    func testGetStudents() async throws {
        try await serviceJsonLaunch { app in
            // Create 3 new students
            let austin = Student(name: "Austin", major: "Computer Science",
                                          school: "Cornell University", age: 21, willGraduate: true)
            let ashley = Student(name: "Ashley", major: "Biology",
                                          school: "Siena & Cornell University", age: 20, willGraduate: true)
            let billy = Student(name: "Billy", major: "Business",
                                         school: "Mira Costa Community", age: 22, willGraduate: false)

            _ = try await app.ferno.create(["Students-get"], body: austin)
            _ = try await app.ferno.create(["Students-get"], body: ashley)
            _ = try await app.ferno.create(["Students-get"], body: billy)

            let names = ["Austin", "Ashley", "Billy"]
            let ages = ["Austin": 21, "Ashley": 20, "Billy": 22]
            let majors = ["Austin": "Computer Science", "Ashley": "Biology", "Billy": "Business"]
            let schools = ["Austin": "Cornell University",
                                              "Ashley": "Siena & Cornell University",
                                              "Billy": "Mira Costa Community"]
            let willGradaute = ["Austin": true,
                                                 "Ashley": true,
                                                 "Billy": false]

            let students: [Student] = try await app.ferno.retrieveMany("Students-get", queryItems: []).map { $0.value }

            XCTAssertNotNil(students)

            XCTAssert(students.count == 3, "Making sure all 3 students are returned")
            students.forEach { student in
                XCTAssert(names.contains(student.name), "Checking name for \(student.name)")
                XCTAssert(ages[student.name] == student.age, "Checking age for \(student.name)")
                XCTAssert(majors[student.name] == student.major, "Checking major for \(student.name)")
                XCTAssert(schools[student.name] == student.school, "Checking school for \(student.name)")
                XCTAssert(willGradaute[student.name] == student.willGraduate, "Checking willGraduate for \(student.name)")
            }

            let success = try await app.ferno.delete("Students-get")

            XCTAssertTrue(success)

        }
    }

    // POST Student
    func testCreateStudent() async throws {
        try await serviceJsonLaunch { app in
            let student = Student(name: "Matt", major: "Computer Science",
                                           school: "Cornell University", age: 20, willGraduate: true)
            let child = try await app.ferno.create(body: student)
            XCTAssertNotNil(child.name)

            let success = try await app.ferno.delete(child.name)

            XCTAssertTrue(success)
        }
    }

    // DELETE student
    func testDeleteStudent() async throws {
        try await serviceJsonLaunch { app in
            let timothy = Student(name: "Timothy", major: "Agriculture",
                                           school: "Mira Costa Community", age: 24, willGraduate: false)

            let child = try await app.ferno.create("Students-delete", body: timothy)

            let success = try await app.ferno.delete(["Students-delete", child.name])
            XCTAssertTrue(success, "did delete child")
        }
    }

    // PATCH update student
    func testUpdateStudent() async throws {
        try await serviceJsonLaunch { app in
            let austin = Student(name: "Austin", major: "Computer Science",
                                          school: "Cornell Univeristy", age: 21, willGraduate: true)
            let child = try await app.ferno.create(["Students-patch"], body: austin)

            let updateStudentInfo = UpdateStudentInfo(major: "Cooking")
            let response = try await app.ferno.update(["Students-patch", child.name], body: updateStudentInfo)
            XCTAssertTrue(response.major == updateStudentInfo.major)

            let success = try await app.ferno.delete(["Students-patch", child.name])

            XCTAssertTrue(success)
        }
    }

    // PUT overwrite student
    func testOverwriteStudent() async throws {
        try await serviceJsonLaunch { app in
            let austin = Student(name: "Austin", major: "Computer Science",
                                          school: "Cornell Univeristy", age: 21, willGraduate: true)
            let child = try await app.ferno.create(["Students-put"], body: austin)

            let teacher = Teacher(name: "Ms. Jennifer", teachesGrade: "12th", age: 29)
            let response: Teacher = try await app.ferno.overwrite(["Students-put", child.name], body: teacher)
            XCTAssertTrue(response.name == teacher.name)

            let success = try await app.ferno.delete(["Students-put", child.name])
            XCTAssertTrue(success)
        }
    }

}
