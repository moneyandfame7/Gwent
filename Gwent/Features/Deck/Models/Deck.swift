//
//  Deck.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import Foundation

struct Deck {
    var leader: Card = .leader()
    var cards: [Card] = []
    var faction: Card.Faction = .northern
}

extension Deck {
    static func sample() -> Deck {
        Deck(
            leader: Card.leader(),
            cards: Array(Card.all()[0 ... 25]),
            faction: .northern
        )
    }

    static func sample2() -> Deck {
        Deck(
            leader: Card.leader(),
            cards: Array(Card.all()[125 ... 150]),
            faction: .monsters
        )
    }
}
