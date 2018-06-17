//
//  Prediction.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//
import Foundation

enum PredictionStatus: Int, Codable {
    case draft = 0, predicted, failed, accurate, deleted
}

final class Prediction: Codable {
    var id: Int?
    var description: String
    let created: Date?
    var status: PredictionStatus?
    init(id: Int? = nil, description: String, status: PredictionStatus? = .draft, created: Date? = nil) {
        self.id = id
        self.description = description
        self.status = status
        if let realDate: Date = created {
            self.created = realDate
        } else {
            self.created = Date()
        }
    }
}
