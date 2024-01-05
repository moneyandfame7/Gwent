//
//  PlayerClass.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 28.12.2023.
//

import Observation
import SwiftUI

@Observable
class PlayerClass {
    var leader: Card
    var cards: [Card] = [] // rename to deck
    /* private(set) */ var discard: [Card] = []
    var hand: [Card] = []
    var rows: [CombatRow]
    var health = 2
    var totalScore: Int {
        rows.reduce(0) { partialResult, combatRow in
            partialResult + combatRow.totalPower
        }
    }

    var isLeaderAvailable = false

    var canPlay: Bool {
        hand.count > 0
    }

    var isPassed = false
    private(set) var isBot: Bool
    init(isBot: Bool = false) {
        leader = Card.leader
        cards = isBot ? Array(Card.all2[0 ... 25]) : Array(Card.all2[125 ... 150])
        rows = CombatRow.generate(isEmpty: true, forBot: isBot)
        self.isBot = isBot
    }

    func pickFromCards(randomHandPosition: Bool = false) {
        let card = cards.first
        guard let card, let index = cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        print("Pick from deck")
        cards.remove(at: index)
        if randomHandPosition {
            let position = hand.randomIndex()
            hand.insert(card, at: position)
        } else {
            hand.append(card)
        }
    }

    // TODO: rename playCard -> moveCard, at -> to
    func moveCard(_ card: Card, row: Card.CombatRow?) {
        let destination: Card.CombatRow? = row ?? card.combatRow

        guard let handIndex = hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        guard let rowIndex = rows.firstIndex(where: { $0.type == destination }) else {
            return
        }
        let randomPositionAtRow = rows[rowIndex].cards.randomIndex()

        var copy = card
        if rows[rowIndex].hasWeather && copy.type != .hero {
            copy.editedPower = 1
        }

        withAnimation(.smooth(duration: 0.3)) {
            hand.remove(at: handIndex)
            // TODO: винести це в окрему функцію в самому рядку
            rows[rowIndex].cards.insert(copy, at: randomPositionAtRow)
        }
    }

    func moveOneToDiscard(_ card: Card) {
        discard.append(card)
    }

    func moveCardsToDiscard() {
        let copy = hand

        hand.removeAll()

        discard.append(contentsOf: copy)
    }

    // TODO: rename addWeatherRow -> applyWeather(_ type: Card.Weather)
    func addWeatherToRow(type: Card.Weather) {
        var rowType: Card.CombatRow

        switch type {
        case .bitingFrost:
            rowType = .close
        case .impenetrableFog:
            rowType = .ranged
        case .torrentialRain:
            rowType = .siege
        default:
            return
        }

        guard let index = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }
        rows[index].hasWeather = true
    }

    func addHorn(_ card: Card, row: Card.CombatRow) {
        guard let handIndex = hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        guard let rowIndex = rows.firstIndex(where: { $0.type == row }) else {
            return
        }
        withAnimation(.smooth(duration: 0.3)) {
            hand.remove(at: handIndex)
            rows[rowIndex].horn = card
        }
    }

    func endRound(isWin: Bool) {
        // move to discard

        withAnimation(.smooth(duration: 0.3)) {
            for i in rows.indices {
                let copy = rows[i].cards

                rows[i].cards.removeAll()
                discard.append(contentsOf: copy)
            }
        }

        // TODO: можливо weathers очищати тут, а не в GwentGame
//        hand.removeAll()

//        discard.append(contentsOf: copy)

        // clear weathers
//        for i in rows.indices {
//            rows[i].hasWeather = false
//        }

        // change health
        if !isWin {
            if health < 1 { return }

            health -= 1
        }
        isPassed = false
    }

    func removeWeathers() {
//        GwentGame(ui: .preview).restar
        for i in rows.indices {
            rows[i].hasWeather = false
        }
    }
}

extension PlayerClass {
    static let preview = PlayerClass()
}
