//
//  Ability.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import Foundation

struct Ability: Codable {
    let name: String
    let description: String
    
    
}

extension Ability {
    static let all: [String: Self] = DataManager.shared.load("abilities.json")

//    {
//        let data: [String: Self] = DataManager.shared.load("abilities.json")
//
//        var newDictionary: [String: Self] = [:]
//
//        for key in data.keys {
//            guard let ability = data[key] else { continue }
//
//            newDictionary.updateValue(ability, forKey: key)
//        }
//
//        return newDictionary
//
//    }()
}
