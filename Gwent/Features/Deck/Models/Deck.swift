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
        leader: Card.all2[82],
        cards: Array(Card.all2[20 ... 40] + [Card.all2[168]]),
        faction: .northern
    )

    static let sample2 = Deck(
        leader: .leader,
        cards: Array(Card.all2[0 ... 20].reversed() + [
            Card.all2[152],
            Card.all2[153],
            Card.all2[154],
            Card.all2[156],
            Card.all2[157],
        ]),
//        Array(Card.all2[70 ... 95]) +
//            [Card.all2[10],
//             Card.all2[11],
//             Card.all2[12]],
        faction: .monsters
    )
}
