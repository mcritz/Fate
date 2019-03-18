//
//  StringRandom.swift
//  App
//
//  Created by Critz, Michael on 3/18/19.
//

import Foundation

// Should only be used for testing.
extension String {
    static func createRandom(length: Int) -> String {
        let characters = CharacterSet.alphanumerics.description
        return String((0...(length - 1)).map{_ in
            characters.randomElement()!
        })
    }
}
