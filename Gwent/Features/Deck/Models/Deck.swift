//
//  Deck.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import Foundation

struct Deck {
    var leader: Card
    var cards: [Card] = []
    let faction: Card.Faction
}

extension Deck {
    static let sample1 = Deck(
        leader: .leader,
        cards: Array(Card.all2[74 ... 99]),
//        Array(Card.all2[70 ... 95]) +
//            [Card.all2[10],
//             Card.all2[11],
//             Card.all2[12]],
        faction: .monsters
    )

    static let sample2 = Deck(
        leader: .leader,
        cards: Array(Card.all2[0 ... 25]),
        faction: .northern
    )
}
