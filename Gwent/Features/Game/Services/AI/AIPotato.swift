//
//  AIPotato.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.01.2024.
//

import Foundation
import OSLog

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "ai-potato"
)

final class AIPotato: AIStrategy {
    var game: GameViewModel

    init(game: GameViewModel) {
        self.game = game
    }

    func startTurn() async {}

    func initialRedraw() {}

    func medic(cards: [Card]) -> Card? {
        if cards.isEmpty {
            return nil
        }

        return cards.randomElement()
    }
}
