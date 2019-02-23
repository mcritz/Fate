//
//  PredictionServer.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//

import FluentPostgreSQL
import Vapor

extension Prediction {
    var topics: Siblings<Prediction, Topic, TopicPivot> {
        return siblings()
    }
}

extension Prediction: PostgreSQLUUIDModel { }

extension Prediction: Migration { }

extension Prediction: Content { }

extension Prediction: Parameter { }
