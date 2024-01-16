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
    var title: String
    let initID: Card.ID?
    var cancelButton: String?
    var onSelect: (Card) -> Void
    var completion: (() -> Void)?

    init(
        cards: [Card],
        count: Int,
        title: String = "",
        initID: Card.ID? = nil,
        cancelButton: String? = nil,
        onSelect: @escaping (Card) -> Void,
        completion: (() -> Void)? = nil

    ) {
        self.cards = cards
        self.count = count
        self.title = title
        self.initID = initID ?? cards.first?.id
        self.cancelButton = cancelButton
        self.onSelect = onSelect
        self.completion = completion
    }
}

extension Carousel {
    static let preview = Carousel(
        cards: Card.inHand,
        count: 2,
//        title: "Select cards lalal",
        onSelect: { card in
            print(" SELECTED - \(card.id)")
        }
    )

    static let redraw = Carousel(
        cards: Card.inHand,
        count: 2,
        title: "Choose a card to redraw.",
        cancelButton: "Finish redrawing",
        onSelect: { card in
            print("Selected - \(card.id)")
        }
    )

    static let pickLeader = Carousel(
        cards: Card.all2.filter { $0.type == .leader && $0.faction == .monsters },
        count: 1,
        title: "Pick your leader",
        cancelButton: "Hide",
        onSelect: { card in
            print("Leader - \(card.name)")
        }
    )
}
