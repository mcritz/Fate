//
//  UserPermissions.swift
//  App
//
//  Created by Michael Critz on 3/9/19.
//

import Foundation

enum Privilege: String, Codable {
    case createPrediction,
    updateOtherUserPrediction,
    createTopic,
    adminUsers
    
    public var allPriviliges: [Privilege] {
        get {
            return [
            .createPrediction,
            .updateOtherUserPrediction,
            .createTopic,
            .adminUsers
            ]
        }
    }
}
