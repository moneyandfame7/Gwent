//
//  Player.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import Observation
import SwiftUI

@Observable
final class Player {
    let rows: [Row]
    let isBot: Bool

    /// Cards stats
    private(set) var deck: Deck
    private(set) var hand: [Card] = []
    private(set) var discardPile: [Card] = []
    private(set) var health = 2
    private(set) var isPassed = false

    var totalScore: Int {
        rows.reduce(0) { $0 + $1.totalPower }
    }

    var canPlay: Bool {
        hand.count > 0 // && isLeaderAvailable
    }

    init(deck: Deck) {
        self.deck = deck
        rows = Row.generate(isBot: false)
        isBot = false
    }

    /// initializer for the bot - (need to add botStrategy)
    init() {
        deck = Deck.sample()
        rows = Row.generate(isBot: true)
        isBot = true
    }

    func moveCard(_ card: Card, row: Card.Row?) {
        let destination = row ?? card.combatRow

        guard let handIndex = hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        guard let row = rows.first(where: { $0.type == destination }) else {
            return
        }

        withAnimation {
            let removed = hand.remove(at: handIndex)
            row.addCard(removed)
        }
    }

    func drawCard(randomHandPosition: Bool = false) {
        guard !deck.cards.isEmpty else {
            return
        }

//        print("Draw from deck")

        let card = deck.cards.removeLast()
        if randomHandPosition {
            hand.insert(card, at: hand.randomIndex())
        } else {
            hand.append(card)
        }
    }

    func passRound() {
        isPassed = true
    }

    func getRow(_ type: Card.Row) -> Row? {
        return rows.first { $0.type == type }
    }

    func removeFromHand(at index: [Card].Index) {
        hand.remove(at: index)
    }

    func moveToDiscard(_ card: Card) {
        discardPile.append(card)
    }

    func endRound(isWin: Bool) {
        clearRows()

        if !isWin {
            if health < 1 { return }

            health -= 1
        }
        isPassed = false
    }

    func applyHorn(_ card: Card, row: Card.Row) {
        guard let handIndex = hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        guard let row = rows.first(where: { $0.type == row }) else {
            return
        }
        withAnimation(.smooth(duration: 0.3)) {
            hand.remove(at: handIndex)
            row.horn = card
        }
    }

    func applyTightBond(_ card: Card, rowType: Card.Row) {
        guard let row = rows.first(where: { $0.type == rowType }) else {
            return
        }

        let bonds = row.cards.filter { $0.name == card.name }

        guard bonds.count > 1 else {
            return
        }

        print("IT IS BOND, JAMES BOND")
        for card in bonds {
            card.editedPower = row.calculateCardPower(card)

            Task { /*@MainActor in*/
                await card.animate()
            }
        }
    }

    func applyMoraleBoost(_ card: Card, rowType: Card.Row) {
        guard let row = getRow(rowType) else {
            return
        }
        row.moraleBoost += 1
    }

    func applyWeather(_ weather: Card.Weather) {
        var rowType: Card.Row

        switch weather {
        case .bitingFrost:
            rowType = .close
        case .impenetrableFog:
            rowType = .ranged
        case .torrentialRain:
            rowType = .siege
        default:
            return
        }
        guard let row = rows.first(where: { $0.type == rowType }) else {
            return
        }

        row.hasWeather = true
    }

    func clearWeathers() {
        for row in rows {
            row.hasWeather = false
        }
    }

    private func clearRows() {
        for row in rows {
            let cards = row.cards

            withAnimation {
                row.cards.removeAll()
                discardPile.append(contentsOf: cards)
            }
        }
    }
}

extension Player {}
