//
//  UsersController.swift
//  App
//
//  Created by Michael Critz on 1/28/19.
//

import Vapor
import Crypto
import Authentication

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("/", "users")
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(String.parameter, use: getUserByUsername)
        usersRoute.get(String.parameter, "predictions", use: getPredictionsByUsername)
        
        
        // Vapor Authentication based protected routes
        // Basic
        let basicAuthMiddleware =
            User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: getToken)
        
        // Token
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let protectedUserRoutes = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        protectedUserRoutes.get(use: getAllHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<Person> {
        user.password = try BCrypt.hash(user.password)
        user.priviliges = [.createPrediction]
        return user.save(on: req).flatMap(to: Person.self) { user -> Future<Person> in
            Future.map(on: req) { try user.convertToPerson() }
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Person]> {
        return User.query(on: req).decode(data: Person.self).all()
    }
    
    func getUserByUsername(_ req: Request) throws -> Future<Person> {
        let stringParameter = try req.parameters.next(String.self)
        let person = User.query(on: req).filter(\.username == stringParameter).first().flatMap(to: Person.self) { matchedUser -> Future<Person> in
            guard let user: User = matchedUser else {
                throw Abort(.notFound)
            }
            return Future.map(on: req) { try user.convertToPerson() }
        }
        return person
    }
    
    func getPredictionsByUsername(_ req: Request) throws -> Future<[Prediction]> {
        let stringParameter = try req.parameters.next(String.self)
        let futureID = User.query(on: req).filter(\.username == stringParameter).first().map(to: UUID.self) { matchedUser -> UUID in
            guard let user: User = matchedUser, user.id != nil else {
                throw Abort(.notFound)
            }
            return user.id!
        }
        return futureID.flatMap { userID -> Future<[Prediction]> in
            return Prediction.query(on: req).filter(\.userID == userID).all()
        }
    }
    
    func getToken(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}
