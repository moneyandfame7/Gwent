//
//  Player.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 28.12.2023.
//

import Observation
import SwiftUI

@Observable
class Player {
    var rows: [Row]
    let isBot: Bool
    var leader: Card

    private(set) var deck: Deck
    /* private(set) */ var hand: [Card] = []
    /* private(set) */ var discard: [Card] = []
    private(set) var health = 2
    private(set) var isPassed = false
    var totalScore: Int {
        rows.reduce(0) { partialResult, combatRow in
            partialResult + combatRow.totalPower
        }
    }

    var isLeaderAvailable = false

    var canPlay: Bool {
        hand.count > 0
    }

    /// Initializer for the player with provided deck.
    init(deck: Deck) {
        self.deck = deck
        leader = deck.leader
        isBot = false
        rows = Row.generate(forBot: false)
        discard = Card.inHand
    }

    /// Initializer for the bot.
    init() {
        deck = Deck.sample2
        leader = Deck.sample2.leader
        isBot = true
        rows = Row.generate(forBot: true)
    }

    func passRound() {
        isPassed = true
    }

    func removeFromHand(at index: [Card].Index) {
        hand.remove(at: index)
    }

    func addToContainer(card: Card, _ container: CardContainer) {
        switch container {
        case .hand:
            hand.append(card)

        case .deck:
            deck.cards.append(card)

        case .discard:
            discard.append(card)

        case let .row(rowType):
            guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
                print("Row index hui pizda")
                fatalError()
            }
            guard let index = rows[rowIndex].cards.firstIndex(where: { $0.id == card.id }) else {
                print("Card container hui pizda")
                fatalError()
            }

                return rows[rowIndex].addCard(card)

        default:
            fatalError("Unsupported container in Player")
        }
    }

    func removeFromContainer(card: Card, _ container: CardContainer) {
        print("RemoveFromContainer")
        switch container {
        case .hand:
            guard let index = hand.firstIndex(where: { $0.id == card.id }) else {
                print("‼️ Not found card in hand")

                return
            }
            hand.remove(at: index)

        case .deck:
            guard let index = deck.cards.firstIndex(where: { $0.id == card.id }) else {
                print("‼️ Not found card in deck")

                return
            }
            deck.cards.remove(at: index)

        case .discard:
            guard let index = discard.firstIndex(where: { $0.id == card.id }) else {
                print("‼️ Not found card in discard")

                return
            }
            discard.remove(at: index)

        case let .row(rowType):
            guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
                print("‼️ Not found row \(rowType)")

                return
            }
            guard let index = rows[rowIndex].cards.firstIndex(where: { $0.id == card.id }) else {
                print("‼️ Not found card in row \(rowType)")

                return
            }
            rows[rowIndex].cards.remove(at: index)

        default:
            fatalError("Unsupported container in Player")
        }
    }

    func drawCard(randomHandPosition: Bool = false) {
        let card = deck.cards.last
        guard let card, let index = deck.cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }

//        print("Pick from deck")
        deck.cards.remove(at: index)
        if randomHandPosition {
            let position = hand.randomIndex()
            hand.insert(card, at: position)
        } else {
            hand.append(card)
        }
    }

    func moveCard(_ card: Card, rowType: Card.Row?, from container: CardContainer = .hand) {
        let destination: Card.Row? = rowType ?? (card.combatRow == .agile ? .close : card.combatRow)

        guard let rowIndex = rows.firstIndex(where: { $0.type == destination }) else {
            return
        }

        withAnimation(.smooth(duration: 0.3)) {
            removeFromContainer(card: card, container)
            rows[rowIndex].addCard(card)
        }
    }

    func getRow(_ rowType: Card.Row) -> Row {
        return rows.first { $0.type == rowType }!
    }

    func moveToDiscard(_ card: Card) {
        discard.append(card)
    }

    func endRound(isWin: Bool) {
        /// Move all cards to discard pile.
        clearRows()

        if !isWin {
            if health < 1 { return }

            health -= 1
        }
        isPassed = false
    }

    private func clearRows() {
        withAnimation(.smooth(duration: 0.3)) {
            for i in rows.indices {
                let cards = rows[i].cards

                rows[i].cards.removeAll()
                discard.append(contentsOf: cards)
            }
        }
    }

    func clearWeathers() {
//        GwentGame(ui: .preview).restar
        for i in rows.indices {
            rows[i].hasWeather = false
        }
    }
}

extension Player {
    static let preview = Player(deck: .sample1)
}

extension Player {
    func applyHorn(_ card: Card, row: Card.Row, from container: CardContainer = .hand) {
        guard let rowIndex = rows.firstIndex(where: { $0.type == row }) else {
            return
        }
        withAnimation(.smooth(duration: 0.3)) {
            removeFromContainer(card: card, container)
            rows[rowIndex].horn = card
        }
    }

    func applyWeather(_ type: Card.Weather) {
        var rowType: Card.Row

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

    func applyTightBond(_ card: Card, rowType: Card.Row) {
        guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }

        let bonds = rows[rowIndex].cards.filter { $0.name == card.name }

        guard bonds.count > 1 else {
            return
        }

        print("IT IS BOND, JAMES BOND")
        for card in bonds {
            guard let cardIndex = rows[rowIndex].cards.firstIndex(where: { $0.id == card.id }) else {
                return
            }

            rows[rowIndex].cards[cardIndex].editedPower = rows[rowIndex].calculateCardPower(card)
            Task { @MainActor in
                rows[rowIndex].cards[cardIndex].shouldAnimate = true

                try? await Task.sleep(for: .seconds(2))

                rows[rowIndex].cards[cardIndex].shouldAnimate = false
            }
        }
    }

    func applyMoraleBoost(_ card: Card, rowType: Card.Row) {
        guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }

        rows[rowIndex].moraleBoost += 1
    }
}
