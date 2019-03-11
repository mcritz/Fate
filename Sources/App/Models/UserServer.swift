import Foundation
import Authentication
import FluentPostgreSQL
import Crypto

extension Person: Content {}

// MARK: Vapor specific
extension User: PostgreSQLUUIDModel {}
extension User: Content {
    func convertToPerson() throws -> Person {
        guard let realID = id else {
            throw Abort(.internalServerError)
        }
        return Person(id: realID, username: username)
    }
}
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
                fatalError("Required Admin values not set in environment")
        }
        let maybeEncryptedPassword = try? BCrypt.hash(password)
        guard let encryptedPassword = maybeEncryptedPassword else {
            fatalError("Admin password could not be encrypted")
        }
        let admin = User(id: nil,
                         email: email,
                         username: username,
                         password: encryptedPassword,
                         privs: [])
        return admin.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
}
