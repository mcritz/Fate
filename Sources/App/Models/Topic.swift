//
//  Topic.swift
//  App
//
//  Created by Critz, Michael on 1/30/19.
//

import Foundation

final class Topic: Codable {
    var id: Int?
    let name: String
    init(name: String) {
        self.name = name
    }
    // MARK: Relations
    var featuredTopicID: UUID?
}
