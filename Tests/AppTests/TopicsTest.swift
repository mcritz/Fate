@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

extension String {
    static func createRandom(length: Int) -> String {
        let characters = CharacterSet.alphanumerics.description
        return String((0...(length - 1)).map{_ in
            characters.randomElement()!
        })
    }
}

final class TopicsTests: XCTestCase {
    var config = Config.default()
    var services = Services.default()
    var env = Environment.testing
    var conn: PostgreSQLConnection?
    var responder: Responder?
    var app: Application?
    
    func configureSUT() throws {
        do {
            try App.configure(&config, &env, &services)
            app = try Application(config: config,
                                  environment: env,
                                  services: services)
            try App.boot(app!)
            conn = try app!.newConnection(to: .psql).wait()
            responder = try app!.make(Responder.self)
        } catch {
            XCTFail("Could not app today")
        }
    }
    
    func createUser(on req: Request) throws -> User {
        return try User(id: nil,
                        email: String.createRandom(length: 22),
                        username: String.createRandom(length: 16),
                        password: String.createRandom(length: 10))
            .save(on: req)
            .wait()
    }
    
    override func setUp() {
        do {
            try configureSUT()
        } catch {
            XCTFail()
        }
    }
    
    override func tearDown() {
        config = Config.default()
        services = Services.default()
        env = Environment.testing
    }
    
    
    func testCreateTopic() {
        var httpRequest = HTTPRequest(method: .GET,
                                  url: URL(string: "/topics")!)
        var req = Request(http: httpRequest, using: app!)
        var response = try! responder?.respond(to: req).wait()
        let data = response?.http.body.data
        let topics = try! JSONDecoder().decode([Topic].self, from: data!)
        
        // Should not have any topics by default
        XCTAssertEqual(topics.count, 0)
        
        
        httpRequest = HTTPRequest(method: .POST, url: URL(string: "/topics")!)
        req = Request(http: httpRequest, using: app!)
        response = try! responder?.respond(to: req).wait()
        
        // Shall not allow posts without authorization
        XCTAssertEqual(response!.http.status, HTTPResponseStatus.unauthorized)
    }
}
