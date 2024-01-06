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
}
