import Foundation
import Authentication
import FluentPostgreSQL
import Crypto

final class User: Codable {
    var id: UUID?
    // FIXME: Neeed to validate email
    let email: String
    let username: String
    var password: String
    init(id: UUID?, email: String, username: String?, password: String) {
        if let id = id {
            self.id = id
        }
        self.email = email
        self.username = username ?? email
        self.password = password
    }
}

// MARK: Vapor specific
extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Parameter {}
extension User: Migration {}
