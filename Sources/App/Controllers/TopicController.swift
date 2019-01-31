//
//  TopicController.swift
//  App
//
//  Created by Critz, Michael on 1/30/19.
//

import Vapor

final class TopicController: RouteCollection {
    func boot(router: Router) throws {
        let topicCollection = router.grouped("topics")
        topicCollection.post(use: self.post)
        topicCollection.get(use: self.index)
        topicCollection.get(Topic.parameter, use: self.fetch)
    }
    func index(_ req: Request) throws -> Future<[Topic]> {
        return Topic.query(on: req).all()
    }
    func post(_ req: Request) throws -> Future<Topic> {
        return try req.content.decode(Topic.self).save(on: req)
    }
    func fetch(_ req: Request) throws -> Future<Topic> {
        return try req.parameters.next(Topic.self)
    }
}
