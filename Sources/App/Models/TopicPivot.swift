//
//  TopicPivot.swift
//  App
//
//  Created by Critz, Michael on 1/30/19.
//

import Vapor
import FluentPostgreSQL

final class TopicPivot: PostgreSQLUUIDPivot, ModifiablePivot {
    
    typealias Left = Topic
    typealias Right = Prediction
    
    var topicID: Topic.ID
    var predictionID: Prediction.ID
    
    static let leftIDKey: LeftIDKey = \.topicID
    static let rightIDKey: RightIDKey = \.predictionID
    
    var id: UUID?
    
    init(_ topic: Topic, _ prediction: Prediction) throws {
        self.topicID = try topic.requireID()
        self.predictionID = try prediction.requireID()
    }
}

extension TopicPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \TopicPivot.topicID, to: \Topic.id, onDelete: .cascade)
            builder.reference(from: \TopicPivot.predictionID, to: \Prediction.id, onDelete: .cascade)
        }
    }
}
