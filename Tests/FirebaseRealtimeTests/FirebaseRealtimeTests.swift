import XCTest
@testable import FirebaseRealtime
@testable import Vapor

struct Class: Content {
    var name: String
    var topic: String
}

struct User: Content {
    var name: String
    var age: String
    var school: String
    var major: String
    var classes: [Class]
}

final class FirebaseRealtimeTests: XCTestCase {
    let data = """
{
    name: "Austin",
    age: "21",
    school: "Cornell University",
    major: "Computer Science",
    classes: [
        {
        name: "CS4410",
        topic: "Operating Systems"
        },
        {
        name: "CS4700",
        topic: "Artificial Intelligence"
        },
        {
        name: "INFO3200",
        topic: "New Meida & Society"
    ]
}
"""


    func singleEntryTest() throws {
        do {
            let decoder = JSONDecoder()

            let body = HTTPBody(string: data)
            let headers: HTTPHeaders = [:]
            let request = HTTPRequest(headers: headers, body: body)
            let futureUser = try decoder.decode(User.self, from: request, maxSize: 65_536, on: EmbeddedEventLoop())

            futureUser.do { user in
                XCTAssertEqual(user.name, "Austin")
                XCTAssertEqual(user.age, "21")
                XCTAssertEqual(user.school, "Cornell University")
                XCTAssertEqual(user.major, "Computer Science")

                }.catch { error in
                    XCTFail(error.localizedDescription)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }

    }
}
