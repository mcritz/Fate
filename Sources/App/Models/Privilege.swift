//
//  UserPermissions.swift
//  App
//
//  Created by Michael Critz on 3/9/19.
//

import Foundation

class Permissions: Codable {
    var privileges: [Privilege]
    init(privileges: [Privilege]) {
        self.privileges = privileges
    }
    func has(privilege: Privilege) -> Bool {
        return privileges.contains(privilege) ? true : false
    }
}

enum Privilege: UInt8, Codable, RawRepresentable {
    case createPrediction = 1,
    updateOtherUserPrediction = 3,
    createTopic = 2,
    adminUsers = 0
    
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
