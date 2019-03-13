//
//  TopicServer.swift
//  App
//
//  Created by Critz, Michael on 1/30/19.
//

import Vapor
import FluentPostgreSQL

extension Topic {
    var predictions: Siblings<Topic, Prediction, TopicPivot> {
        return siblings()
    }
}

extension Topic: PostgreSQLModel {}
extension Topic: Migration {}
extension Topic: Content {}
extension Topic: Parameter {}
extension Topic {
    var featuredTopic: Parent<Topic, FeaturedTopic> {
        // FIXME: Not this!
        return parent(\.featuredTopicID)! // OHNOES!
    }
}
