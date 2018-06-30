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
    var status: PredictionStatus
    init(id: Int? = nil, description: String, status: PredictionStatus? = .draft) {
        self.id = id
        self.description = description
        if let realStatus: PredictionStatus = status {
            self.status = realStatus
        } else {
            self.status = .draft
        }
    }
}
