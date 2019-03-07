//
//  Token.swift
//  App
//
//  Created by Michael Critz on 3/5/19.
//

import Vapor
import Authentication
import FluentPostgreSQL

extension Token {
    static func generate(for user: User) throws -> Token {
        let rando = try CryptoRandom().generateData(count: 16)
        return try Token(token: rando.base64EncodedString(), userID: user.requireID())
    }
}

extension Token: PostgreSQLUUIDModel {}
extension Token: Content {}

extension Token: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Token: Authentication.Token, BearerAuthenticatable {
    typealias UserType = User
    typealias UserIDType = User.ID
    static let tokenKey: TokenKey = \Token.token
    static let userIDKey: UserIDKey = \Token.userID
}
