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
        cards: [
            
            Card.all2[53],
            Card.all2[67],

            Card.all2[101],
            Card.all2[110],
            Card.all2[111],
            Card.all2[115],
            Card.all2[117],
            Card.all2[118],
            Card.all2[124],
            Card.all2[127],

            Card.all2[138],
            Card.all2[151],
            Card.all2[168],
            Card.all2[175],
            Card.all2[155],
            Card.all2[193],
            Card.all2[37],
            Card.all2[28],
            Card.all2[30],
            Card.all2[31],
            Card.all2[32],
        ],
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
