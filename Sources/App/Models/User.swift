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
        self.id = id
        self.email = email
        self.username = email
        self.password = password
    }
}

// MARK: Vapor specific
extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Parameter {}
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username as! User.UsernameKey
    static let passwordKey: PasswordKey = \User.password 
}
