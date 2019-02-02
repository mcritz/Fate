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
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
}
