//
//  FactionTab.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 24.01.2024.
//

import Foundation
enum FactionTab: String, CaseIterable {
    case northern
    case nilfgaard
    case monsters
    case scoiatael

    var description: String {
        switch self {
        case .northern:
            return "Draw a card from your deck whenever you win a round."
        case .nilfgaard:
            return "Wins any round that ends in a draw."
        case .monsters:
            return "Keeps a random Unit Card out after each round."
        case .scoiatael:
            return "Decides who takes first turn."
        }
    }
    

    var title: String {
        switch self {
        case .northern:
            return "Northern Realms"
        case .nilfgaard:
            return "Nilfgaardian Empire"
        case .monsters:
            return "Monsters"
        case .scoiatael:
            return "Scoiatael"
        }
    }
}
