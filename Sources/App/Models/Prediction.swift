//
//  Prediction.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//
import Foundation

enum PredictionStatus: Int, Codable {
    case draft = 0, predicted, failed, accurate, partiallyAccurate, deleted
    func description() -> String {
        switch self {
        case .failed:
            return "False"
        case .accurate:
            return "True"
        case .partiallyAccurate:
            return "Kinda True"
        default:
            return "Predicted"
        }
    }
}

final class Prediction: Codable {
    var id: UUID?
    let description: String
    var status: PredictionStatus
    init(id: UUID? = nil, description: String, status: PredictionStatus? = .draft, userID: UUID) {
        self.id = id
        self.description = description
        if let realStatus: PredictionStatus = status {
            self.status = realStatus
        } else {
            self.status = .draft
        }
        self.userID = userID
    }
    // MARK: Relations
    var userID: UUID
}
