//
//  PredictionController.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//

import Vapor

final class PredictionController: RouteCollection {
    func boot(router: Router) throws {
        let predictionsRoutes = router.grouped("predictions")
        predictionsRoutes.get(use: self.index)
        predictionsRoutes.post(use: self.create)
        predictionsRoutes.get(Prediction.parameter, use: self.get)
        predictionsRoutes.put(Prediction.parameter, use: self.updatePrediction)
        predictionsRoutes.get(Prediction.parameter, "topics", use: self.getTopics)
        predictionsRoutes.post(Prediction.parameter, "topics", Topic.parameter, use: self.addTopic)
        predictionsRoutes.delete(Prediction.parameter, "topics", Topic.parameter, use: self.removeTopic)
    }

    func index(_ req: Request) throws -> Future<[Prediction]> {
        return Prediction.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Prediction> {
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
    
    func updatePrediction(_ req: Request) throws -> Future<Prediction> {
        let maybeOldPrediction = try req.parameters.next(Prediction.self)
        return maybeOldPrediction.flatMap { oldPredix -> Future<Prediction> in
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
    
    func addTopic(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Prediction.self), req.parameters.next(Topic.self)) { prediction, topic in
            return prediction.topics.attach(topic, on: req).transform(to: .created)
        }
    }
    
    func removeTopic(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Prediction.self), req.parameters.next(Topic.self)) { prediction, topic in
            return prediction.topics.detach(topic, on: req).transform(to: .ok)
        }
    }
}
