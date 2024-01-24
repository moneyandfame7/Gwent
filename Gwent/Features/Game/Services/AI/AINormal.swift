//
//  AINormal.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.01.2024.
//

import Foundation
import OSLog

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "ai-normal"
)

private struct BoardData {
    // Rewrite to [Card.Row: [Card]]
    let spy: Bool
    let medic: Bool
    let max: Bool
}

final class AINormal: AIStrategy {
    var game: GameViewModel

    init(game: GameViewModel) {
        self.game = game
    }

    func startTurn() async {
        let data = getBoardData()

        let values = getCardValues(data: data, game.bot.hand)

        guard let cardToPlay = values[.high]?.randomElement() ?? values[.default]?.randomElement() ?? values[.low]?
            .randomElement() ?? values[.none]?.randomElement()
        else {
            return
        }

        if cardToPlay.ability == .decoy {
            if data.spy {
                
            }
//                game.playDecoy(cardToPlay, target: <#T##Card#>, rowType: <#T##Card.Row#>)
        }
    }

    func initialRedraw() {}

    func medic(cards: [Card]) -> Card? {
        if cards.isEmpty {
            return nil
        }

        return cards.max(by: { $0.availablePower ?? 0 < $1.availablePower ?? 0 })
    }
}

private extension AINormal {
    typealias CardValues = [Card.Value: [Card]]

    func getCardValues(data: BoardData, _ cards: [Card]) -> CardValues {
        var values: CardValues = [:]

        for card in cards {
            let value = getCardValue(data: data, card)

            values[value, default: []].append(card)
        }

        return values
    }

    /// Returns the value of the card relative to the current state of the board.
    func getCardValue(data: BoardData, _ card: Card) -> Card.Value {
        if card.ability == .decoy {
            return data.spy ? .high : data.medic ? .high : data.max ? .low : .none
        }

        if card.ability == .spy {
            return .high
        }

        if card.ability == .commanderHorn {
            return getHornValue()
        }

        if card.ability == .medic {
            return getMedicValue()
        }

        return .default
    }

    func getHornValue() -> Card.Value {
        let rows = game.bot.rows.filter { $0.horn == nil }

        if rows.isEmpty {
            return .none
        }

        return .default
    }

    func getMedicValue() -> Card.Value {
        let units = game.bot.discard.filter { $0.type == .unit }

        if units.isEmpty {
            return .default
        }

        let data = getCardsData(units)

        return data.spy ? .high : data.medic ? .high : data.max ? .low : .none
    }

    /// Returns data from the AI rows about the abilities of cards (without a hero).
    func getBoardData() -> BoardData {
        let spy = game.bot.rows.contains(where: { $0.cards.contains(where: { $0.ability == .spy }) })

        let medic = game.bot.rows.contains(where: { $0.cards.contains(where: { $0.ability == .medic }) })

        let max = game.bot.rows
            .flatMap { $0.cards
                .filter { $0.type != .hero }
                .compactMap { $0.availablePower }
            }
            .max() != nil

        return BoardData(spy: spy, medic: medic, max: max)
    }

    func getCardsData(_ cards: [Card]) -> BoardData {
        let spy = cards.contains { $0.ability == .spy }

        let medic = cards.contains { $0.ability == .medic }

        let max = cards.max(by: { ($0.availablePower ?? 0) < ($1.availablePower ?? 0) }) != nil

        return BoardData(spy: spy, medic: medic, max: max)
    }
}
