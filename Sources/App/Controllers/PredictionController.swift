//
//  PredictionController.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//

import Vapor
import Crypto
import Authentication

final class PredictionController: RouteCollection {
    func boot(router: Router) throws {
        let predictionsRoutes = router.grouped("predictions")
        predictionsRoutes.get(use: self.index)
        predictionsRoutes.get(Prediction.parameter, use: self.get)
        predictionsRoutes.get(Prediction.parameter, "topics", use: self.getTopics)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let protectedPredictionRoutes = predictionsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        protectedPredictionRoutes.post(use: self.create)
        protectedPredictionRoutes.put(Prediction.parameter, use: self.updatePrediction)
        protectedPredictionRoutes.delete(Prediction.parameter, "topics", Topic.parameter, use: self.removeTopic)
        protectedPredictionRoutes.post(Prediction.parameter, "topics", Topic.parameter, use: self.addTopic)
    }

    func index(_ req: Request) throws -> Future<[Prediction]> {
        return Prediction.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Prediction> {
        guard try User.hasPrivilige(privilege: .createPrediction, on: req) else {
            throw Abort(.unauthorized)
        }
        return try req.content.decode(Prediction.self).flatMap { predix in
            let futureTopic = req.content.get(Int.self, at: "topicID").flatMap(to: Topic.self) { topicID -> Future<Topic> in
                return Topic.find(topicID, on: req) ?? Topic.init(name: "Uncategorized")
            }
            // FIXME: Bad smell. There is probably room for improvement here.
            // Add the prediction when the promise is fulfilled
            _ = futureTopic.do { topic in
                _ = topic.predictions.attach(predix, on: req)
            }.catch { error in
                print("Failed to add topic on prediction creation. \r", error)
            }
            return predix.save(on: req)
        }
    }
    
    // MARK: Permissions
    // FIXME: Generalize this function to make models and perms more reusable
    /// Creates a `Bool` on the same container as this `Request`.
    /// Intended use is to chain `Future`
    ///
    ///    let maybeOldPrediction = try canEdit(with: req).map(to: Request.self) { isAuthorized in
    ///        guard isAuthorized else { throw Abort(.unauthorized) }
    ///        return req
    ///        }.flatMap(to: Prediction.self) { req in
    ///            return try req.parameters.next(Prediction.self)
    ///    }
    ///
    /// - parameters:
    ///     - request: Required `Request` to find Model<Prediction>
    /// - returns: `Future<Bool>` true if user can edit request’s `Prediction`
    func canEdit(with request: Request) throws -> Future<Bool> {
        let user = try request.requireAuthenticated(User.self)
        
        // FIXME: This could break
        // If the request contains a user, but not a saved prediction
        // because it returns true before the prediction has been queried.
        if user.priviliges.contains(.updateOtherUserPrediction) {
            return Future.map(on: request) { true }
        }
        
        return try request.parameters.next(Prediction.self).map(to: Bool.self) { predix -> Bool in
            if let realID = user.id,
                realID == predix.userID {
                return true
            }
            return false
        }
    }
    
    func updatePrediction(_ req: Request) throws -> Future<Prediction> {
        // MARK: Perms check
        let maybeOldPrediction = try canEdit(with: req).map(to: Request.self) { isAuthorized in
            guard isAuthorized else { throw Abort(.unauthorized) }
            return req
        }.flatMap(to: Prediction.self) { req in
            return try req.parameters.next(Prediction.self)
        }
        return maybeOldPrediction.flatMap { oldPredix -> Future<Prediction> in
            // MARK: Update content
            let maybeNewPrediction = try req.content.decode(Prediction.self)
            return maybeNewPrediction.map { newPredix in
                let constructedPrediction = newPredix
                constructedPrediction.id = oldPredix.id
                return constructedPrediction
            }.save(on: req)
        }
    }
    
    func get(_ req: Request) throws -> Future<Prediction> {
        return try req.parameters.next(Prediction.self)
    }
    
    func getTopics(_ req: Request) throws -> Future<[Topic]> {
        return try req.parameters.next(Prediction.self).flatMap(to: [Topic].self) { prediction in
            return try prediction.topics.query(on: req).all()
        }
    }
    
    // FIXME: Future chains are far too confusing
    func addTopic(_ req: Request) throws -> Future<HTTPStatus> {
        // Perms check returns a `Future<Bool>` that chains…
        return try canEdit(with: req).map(to: Request.self) { isAuthorized throws in
            guard isAuthorized else { throw Abort(.unauthorized) }
            return req
        }.flatMap(to: HTTPStatus.self) { req in
            // Take in the request, attach prediction to topic, and return 201
            return try flatMap(to: HTTPStatus.self,
                               req.parameters.next(Prediction.self),
                               req.parameters.next(Topic.self)) { prediction, topic in
                return prediction.topics.attach(topic, on: req).transform(to: .created)
            }
        }
    }
    
    func removeTopic(_ req: Request) throws -> Future<HTTPStatus> {
        return try canEdit(with: req).map(to: Request.self) { isAuthorized throws in
            guard isAuthorized else { throw Abort(.unauthorized) }
            return req
        }.flatMap(to: HTTPStatus.self) { req in
            return try flatMap(to: HTTPStatus.self,
                               req.parameters.next(Prediction.self),
                               req.parameters.next(Topic.self)) { prediction, topic in
                return prediction.topics.detach(topic, on: req).transform(to: .ok)
            }
        }
    }
}
