//
//  GameAI.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 08.01.2024.
//

import SwiftUI

enum Difficulty: String, CaseIterable {
    case potato, normal

    var description: String {
        switch self {
        case .potato:
            "Potato"
        case .normal:
            "Normal"
        }
    }
}

//
// protocol GameAI {
// func startTurn() async
// }
//
// class GameAIPotato: GameAI {}
//
// class GameAINormal: GameAI {}

final class AI {
    /// Bi-directional usage.
    private unowned var game: GameViewModel!

    private(set) var strategy: AIStrategy!

    init(game: GameViewModel, difficulty: Difficulty) {
        self.game = game
        setDifficulty(difficulty)
    }

    func setDifficulty(_ difficulty: Difficulty) {
        switch difficulty {
        case .normal:
            strategy = AINormal(game: game)
        case .potato:
            strategy = AIPotato(game: game)
        }
    }
}

final class GameAI {
    private unowned var game: GameViewModel

    init(game: GameViewModel) {
        self.game = game

        print("✅ GameAI - Init -")
    }

    deinit {
        print("‼️ GameAI - Deinit -")
    }

    @MainActor
    func startTurn() async {
        guard let opponent = game.opponent else {
            return
        }

        /// Якщо AI в переможній ситуації, а гравець вже пасанув - AI пасує.
        if let leadingPlayer = game.leadingPlayer, leadingPlayer.isBot && opponent.isPassed {
            return await game.passRound()
        }

        /// На кількість карток перевіряємо в turnEnd і roundStart,  тому force unwrap ????
        let card = game.bot.hand.randomElement()!

        if card.ability == .agile {
            let randomRow = Int.random(in: 0 ... 1)
            await game.playCard(card, rowType: randomRow == 0 ? .close : .ranged)
        } else {
            await game.playCard(card)
        }
    }

    /// In GameAI difficulty робити це не рандомно
    func initialRedraw() {
        for _ in 0 ..< 2 {
            withAnimation(.card) {
                let randomToRemove = game.bot.hand.randomElement()!
                game.bot.removeFromContainer(card: randomToRemove, .hand)
                game.bot.addToContainer(card: randomToRemove, .deck)

                let randomToRetrieve = game.bot.deck.cards.randomElement()!
                game.bot.removeFromContainer(card: randomToRetrieve, .deck)
                game.bot.addToContainer(card: randomToRetrieve, .hand)
            }
        }
    }

    /// Обирає найсильнішу картку з наданих карток і повертає її
    func medic(cards: [Card]) {
//        cards.max(by: {$0.availablePower < $1.availablePower})
    }

    /// Обирати рандомну картку: GameAINormal
    /// якщо немає сенсу використовувати - перевебирання або пасувати
    /// якщо це скорч - юзати якщо має сенс ( у плеєра має бути декілька карток з однаковою силою чи шось таке )
    /// якщо це horn - на рядок, де найбільша сила
    ///
    /// GameAIPotato: просто рандомно
}
