//
//  Carousel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 07.01.2024.
//

import Foundation

struct Carousel {
    var cards: [Card] = []

    var count: Int
    var title: String = ""
    var action:  (Card) -> Void
}

extension Carousel {
    static let preview = Carousel(
        cards: Card.inHand,
        count: 2,
//        title: "Select cards lalal",
        action: { card in
            print(" SELECTED - \(card.id)")
        }
    )
}
