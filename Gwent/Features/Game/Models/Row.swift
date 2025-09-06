//
//  Row.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

struct Row {
    let type: Card.Row

    /* private(set) */ var cards: [Card] = []

    var horn: Card?

    var showHornOverlay = false

    var hasWeather = false {
        didSet {
            calculateCardsPower()
        }
    }

    var hornEffects = 0 {
        didSet {
            calculateCardsPower()
        }
    }

    var moraleBoost = 0 {
        didSet {
            calculateCardsPower()
        }
    }

    var totalPower: Int {
        cards.reduce(0) { $0 + ($1.availablePower ?? 0) }
    }

    mutating func addHorn(_ card: Card) {
        if horn != nil {
            return
        }
//        withAnimation(.smooth(duration: 0.3)) {
        horn = card
//        }
        hornEffects += 1
    }

    mutating func applyHorn(_ card: Card) async {}

    mutating func addCard(_ card: Card, at: Int? = nil) {
        var copy = card
        copy.editedPower = calculateCardPower(copy)

        let randomPositionAtRow = cards.randomIndex()

        cards.insert(copy, at: at ?? randomPositionAtRow)
    }

    mutating func removeCard(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        removeCard(at: index)
    }

    mutating func removeCard(at: Int) {
        let removed = cards.remove(at: at)

        switch removed.ability {
        case .commanderHorn:
            hornEffects -= 1
        case .moraleBoost:
            moraleBoost -= 1
        default:
            return
        }
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

    mutating func test() {
        hasWeather = true
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
