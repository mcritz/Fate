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
        topicCollection.get(Topic.parameter, "predictions", use: self.predictions)
        topicCollection.post(Topic.parameter, "predictions", Prediction.parameter, use: self.addPrediction)
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
    func predictions(_ req: Request) throws -> Future<[Prediction]> {
        return try req.parameters.next(Topic.self).flatMap(to: [Prediction].self) { topic in
            return try topic.predictions.query(on: req).all()
        }
    }
    func addPrediction(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Topic.self),
            req.parameters.next(Prediction.self)) { topic, prediction in
                return prediction.topics.attach(topic, on: req).transform(to: .created)
            }
    }
}
