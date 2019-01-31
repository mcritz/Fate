//
//  PredictionController.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//

import Vapor

final class PredictionController: RouteCollection {
    func boot(router: Router) throws {
        router.get("predictions", use: self.index)
        router.post("predictions", use: self.create)
    }

    func index(_ req: Request) throws -> Future<[Prediction]> {
        return Prediction.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Prediction> {
        return try req.content.decode(Prediction.self).flatMap { predix in
            return predix.save(on: req)
        }
    }
}
