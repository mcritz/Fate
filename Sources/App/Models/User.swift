import Foundation
import Authentication
import FluentPostgreSQL

final class User: Codable {
    var id: UUID?
    // FIXME: Neeed to validate email
    let email: String
    let username: String
    let password: String
    init(email: String, password: String) {
        self.email = email
        self.username = email
        self.password = password
    }
}

// MARK: Vapor specific
extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Parameter {}
extension User: Migration {}
