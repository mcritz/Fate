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
}
