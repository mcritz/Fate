@testable import App
import Vapor
import Authentication
import XCTest
import FluentPostgreSQL

final class UserTest: XCTestCase {
    func testGetUsers() throws {
        // MARK: Mock SUT
        let testUsername = String.createRandom(length: 15)
        let testPassword = String.createRandom(length: 10)
        let testEmail = String.createRandom(length: 15)

        var configuration = Config.default()
        var env = Environment.testing
        var services = Services.default()

        try App.configure(&configuration, &env, &services)
        let app = try Application(config: configuration, environment: env, services: services)
        try App.boot(app)

        let dbConnection = try app.newConnection(to: .psql).wait()
        let user = User(id: nil, email: testEmail, username: testUsername, password: testPassword)
        let savedUser = try user.save(on: dbConnection).wait()

        let responder = try app.make(Responder.self)
        
        // MARK: - Basic Auth
        
        let credentials = BasicAuthorization.init(username: testEmail, password: testPassword)
        var authHeaders = HTTPHeaders.init()
        authHeaders.basicAuthorization = credentials
        
        // MARK: - Token Auth
        
        let tokenRequest = HTTPRequest(method: .POST, url: URL(string: "/users/login")!, headers: authHeaders)
        var wrappedRequest = Request(http: tokenRequest, using: app)
        var response = try responder.respond(to: wrappedRequest).wait()
        var data = response.http.body.data
        let token = try response.content.syncDecode(Token.self)
        authHeaders = HTTPHeaders.init()
        authHeaders.add(name: .authorization, value: "Bearer \(token.token)")
        
        // MARK: - GET/users
        
        let reqAllUsers = HTTPRequest(method: .GET, url: URL(string: "/users")!, headers: authHeaders)
        wrappedRequest = Request(http: reqAllUsers, using: app)

        response = try responder.respond(to: wrappedRequest).wait()
        data = response.http.body.data
        let people = try JSONDecoder().decode([Person].self, from: data!)

        XCTAssertEqual(people.count, 2, "DB has two users admin & mock user")
        XCTAssertTrue(people.contains(where: { person in
            person.username == savedUser.username
        }), "get/users contains our user")
        XCTAssertTrue(people.contains(where: { person in
            person.id == savedUser.id!
        }), "get/users contains our user id")
        
        
        // MARK: - GET/username
        
        let reqSingleUser = HTTPRequest(method: .GET, url: URL(string: "/users/\(savedUser.username)")!, headers: authHeaders)
        wrappedRequest = Request(http: reqSingleUser, using: app)
        response = try responder.respond(to: wrappedRequest).wait()
        data = response.http.body.data
        let person = try JSONDecoder().decode(Person.self, from: data!)
        
        XCTAssertEqual(person.username, savedUser.username, "GET/user uses the db saved username value as a URL path")
        dbConnection.close()
    }
}
