//
//  TopicController.swift
//  App
//
//  Created by Critz, Michael on 1/30/19.
//

import Vapor
import Crypto
import Authentication

final class TopicController: RouteCollection {
    // MARK: Routing
    func boot(router: Router) throws {
        let topicCollection = router.grouped("topics")
        topicCollection.get(use: self.index)
        topicCollection.get(Topic.parameter, use: self.fetch)
        topicCollection.get(Topic.parameter, "predictions", use: self.predictions)
        topicCollection.get("featured", use: self.fetchFeatured)
        topicCollection.post("featured", use: self.createFeatured)
        topicCollection.post(Topic.parameter, "featured", FeaturedTopic.parameter, use: self.addToFeatured)
        topicCollection.delete(Topic.parameter, "featured", FeaturedTopic.parameter, use: self.removeFromFeatured)
        topicCollection.post(Topic.parameter, "predictions", Prediction.parameter, use: self.addPrediction)
        
        // MARK: Protected Routes
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardMiddleware = User.guardAuthMiddleware()
        let topicProtectedRoutes = topicCollection.grouped(tokenAuthMiddleware, guardMiddleware)
        topicProtectedRoutes.post(use: self.post)
        topicProtectedRoutes.put(Topic.parameter, use: self.update)
    }
    
    // MARK: - Handlers
    func index(_ req: Request) throws -> Future<[Topic]> {
        return Topic.query(on: req).all()
    }
    func post(_ req: Request) throws -> Future<Topic> {
        return try req.content.decode(Topic.self).save(on: req)
    }
    
    func update(topic req: Request) throws -> Future<Topic> {
        let maybeOldTopic = try req.parameters.next(Topic.self)
        return maybeOldTopic.flatMap { oldTopic -> Future<Topic> in
            let maybeNewTopic = try req.content.decode(Topic.self)
            return maybeNewTopic.map { newTopic in
                let constructedTopic = newTopic
                constructedTopic.id = oldTopic.id
                return constructedTopic
            }
        }.save(on: req)
    }
    
    func fetch(_ req: Request) throws -> Future<Topic> {
        return try req.parameters.next(Topic.self)
    }
    func fetchFeatured(_ req: Request) throws -> Future<[Topic]> {
        return Topic.query(on: req).join(\FeaturedTopic.id, to: \Topic.featuredTopicID).sort(\FeaturedTopic.priority).all()
    }
    func createFeatured(_ req: Request) throws -> Future<FeaturedTopic> {
        return try req.content.decode(FeaturedTopic.self).save(on: req)
    }
    func addToFeatured(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Topic.self),
            req.parameters.next(FeaturedTopic.self)) { oldTopic, featuredTopic in
                return featuredTopic.save(on: req).flatMap(to: Topic.self, { (fTopic) in
                    guard let newFeaturedTopicID = fTopic.id else {
                        throw Abort(.internalServerError)
                    }
                    oldTopic.featuredTopicID = newFeaturedTopicID
                    return oldTopic.save(on: req)
                }).transform(to: .ok)
            }
    }
    func removeFromFeatured(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Topic.self),
            req.parameters.next(FeaturedTopic.self)) { oldTopic, featuredTopic in
                oldTopic.featuredTopicID = nil
                return oldTopic.save(on: req).transform(to: .ok)
        }
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
