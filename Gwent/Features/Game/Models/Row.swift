//
//  Row.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

struct Row {
    let type: Card.Row

    /*private(set)*/ var cards: [Card] = []

    var horn: Card?

    private(set) var showHornOverlay = false

    var hasWeather = false {
        didSet {
            calculateCardsPower()
        }
    }

    /// Processed in RowView
    var hornEffects: Int {
        cards.reduce(0) { $0 + ($1.ability == .commanderHorn ? 1 : 0) } + (horn != nil ? 1 : 0)
    }

    /// Processed in RowView
    var moraleBoost: Int {
        cards.reduce(0) { $0 + ($1.ability == .moraleBoost ? 1 : 0) }
    }

    var totalPower: Int {
        /// $0 - prevResult, $1 - item
        cards.reduce(0) { $0 + ($1.editedPower ?? $1.power ?? 0) }
    }

    @MainActor
    mutating func addHorn(_ card: Card) async {
        if horn != nil {
            return
        }

        withAnimation(.smooth(duration: 0.3)) {
            horn = card
        }

        showHornOverlay = true

        try? await Task.sleep(for: .seconds(1))

        showHornOverlay = false
//
    }

    mutating func addCard(_ card: Card, at: Int? = nil) {
        var copy = card
        copy.editedPower = calculateCardPower(copy)

        let randomPositionAtRow = cards.randomIndex()

        cards.insert(copy, at: at ?? randomPositionAtRow)
    }

    mutating func removeCard(_ card: Card) {}

    mutating func removeCard(at: Int) {
        cards.remove(at: at)
    }

    func calculateCardPower(_ card: Card) -> Int? {
        var total: Int = card.power ?? 0
        if card.type == .hero || card.ability == .decoy {
            return nil
        }

        if hasWeather {
            total = 1
        }

        let bonds = cards.filter { $0.name == card.name }

        if card.ability == .tightBond && bonds.count > 1 {
            total *= bonds.count
        }

        // -1 --> тому що абілка додає до всіх карток ОКРІМ себе
        total += max(0, moraleBoost + (card.ability == .moraleBoost ? -1 : 0))

        if (hornEffects - (card.ability == .commanderHorn && card.type == .unit ? 1 : 0)) > 0 {
            print("Ця картка НЕ ДАНДАЛІОН ЙОБАНИЙ: \(card.name)")

            total *= 2
        }

        return total
    }

    mutating func calculateCardsPower() {
        for i in cards.indices {
            cards[i].editedPower = calculateCardPower(cards[i])
        }
    }
}

extension Row {
    static func generate(isEmpty: Bool = false, forBot: Bool = false) -> [Self] {
        return [
            Row(type: .close),
            Row(type: .ranged),
            Row(type: .siege),
        ].reversed(forBot)
    }
}
