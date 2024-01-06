//
//  BotStrategy.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

// import Observation
// import SwiftUI
//
// @Observable
// final class BotStrategy {
//
// }
import Observation

@Observable
final class BotStrategy {
    private unowned var game: GameViewModel!

    func connectGame(game: GameViewModel) {
        self.game = game
        
        print("BotStrategy <-- 📶Game connected -->")
    }

    func startTurn() async {
        guard let opponent = game.opponent else {
            return
        }
        /// Якщо бот в переможній ситуації і вже пасанули - теж пасує.
        if let leading =  game.leadingPlayer, opponent.isPassed && leading.isBot {
            await game.passRound()
            return
        }
//        /// На кількість карток перевіряємо в turnEnd і roundStart,  тому force unwrap ????
//        let card = game.bot.hand.randomElement()!
//
//        if card.ability == .agile {
//            let randomRow = Int.random(in: 0 ... 1)
//            await playCard(card, row: randomRow == 0 ? .close : .ranged)
//        } else {
//            await playCard(card)
//        }
    }
    
    init() {
        print("BotStrategy <-- ✅Init -->")
    }

    deinit {
        print("BotStrategy <-- ⛔️Deinit -->")
    }
}

// struct BotStrategyService {
//    func generateDeck() -> Void {
////        let faction = Card.Faction.allCases.filter { $0 != .neutral }
////
////        let leader = Card.all2.first
//    }
// }
