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
        
        
        // Vapor Authentication based protected routes
        let basicAuthMiddleware =
            User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: getToken)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let protectedUserRoutes = usersRoute.grouped(basicAuthMiddleware, guardAuthMiddleware)
        protectedUserRoutes.get(use: getAllHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getUserByUsername(_ req: Request) throws -> Future<User> {
        let stringParameter = try req.parameters.next(String.self)
        return User.query(on: req).filter(\.username == stringParameter).first().flatMap(to: User.self) { matchedUser -> Future<User> in
            guard let user: User = matchedUser else {
                throw Abort(.notFound)
            }
            return Future.map(on: req) { user }
        }
    }
    
    func getToken(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}
