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
        predictionsRoutes.get(Prediction.parameter, "topics", use: self.getTopic)
        predictionsRoutes.post(Prediction.parameter, "topics", Topic.parameter, use: self.addTopic)
    }

    func index(_ req: Request) throws -> Future<[Prediction]> {
        return Prediction.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Prediction> {
        return try req.content.decode(Prediction.self).flatMap { predix in
            return predix.save(on: req)
        }
    }
    
    func get(_ req: Request) throws -> Future<Prediction> {
        return try req.parameters.next(Prediction.self)
    }
    
    func getTopic(_ req: Request) throws -> Future<[Topic]> {
        return try req.parameters.next(Prediction.self).flatMap(to: [Topic].self) { prediction in
            return try prediction.topics.query(on: req).all()
        }
    }
    
    func addTopic(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Prediction.self), req.parameters.next(Topic.self)) { prediction, topic in
            return prediction.topics.attach(topic, on: req).transform(to: .created)
        }
    }
}
