@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTest: XCTestCase {
    func testGetUsers() throws {
        let testName = "Jonathan Longnamerson"
        let testUsername = "jonathan.longnamerson"
        let testEmail = "nope"

        var configuration = Config.default()
        var env = Environment.testing
        var services = Services.default()

        try App.configure(&configuration, &env, &services)
        let app = try Application(config: configuration, environment: env, services: services)
        try App.boot(app)

        let dbConnection = try app.newConnection(to: .psql).wait()
        let user = User(id: nil, email: testEmail, username: nil, password: "supersecret")
        let savedUser = try user.save(on: dbConnection).wait()

        let responder = try app.make(Responder.self)
        let req = HTTPRequest(method: .GET, url: URL(string: "/users")!)
        let wrappedRequest = Request(http: req, using: app)

        let response = try responder.respond(to: wrappedRequest).wait()
        let data = response.http.body.data
        let users = try JSONDecoder().decode([User].self, from: data!)

        // MARK: - Test Cases
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].username, testName)
        XCTAssertEqual(users[0].email, testUsername)
        XCTAssertEqual(users[0].id, savedUser.id)

        dbConnection.close()
    }
}
