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

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

// TODO: Load admin password from env, then seed database. See book, pp 427..43x
struct AdminUser: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let adminUsername = Environment.get("KRZN_ADMIN_USERNAME")
        let adminEmail = Environment.get("KRZN_ADMIN_EMAIL")
        let envPassword = Environment.get("KRZN_ADMIN_PASSWORD")
        guard let password = envPassword, password.count > 7,
            let username = adminUsername,
            let email = adminEmail
            else {
            fatalError("Admin password not set in environment")
        }
        let maybeEncryptedPassword = try? BCrypt.hash(password)
        guard let encryptedPassword = maybeEncryptedPassword else {
            fatalError("Admin password could not be encrypted")
        }
        let admin = User(id: nil, email: email, username: username, password: encryptedPassword)
        return admin.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
}
