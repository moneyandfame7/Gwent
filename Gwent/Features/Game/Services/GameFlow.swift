//
//  GameFlow.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 08.01.2024.
//

import SwiftUI

final class GameFlow {
    private unowned let game: GameViewModel

    init(game: GameViewModel) {
        self.game = game

        print("✅ GameFlow - Deinit -")
    }

    deinit {
        print("‼️ GameFlow - Deinit -")
    }

    func startGame() async {
        await flipCoin()

        for _ in 0 ..< 10 {
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.smooth(duration: 0.3)) {
                game.player.drawCard()
                game.bot.drawCard()
            }
        }

        await startRound()
    }

    func restartGame() {}

    func endGame() async {
        withAnimation {
            game.isGameOver = true
        }
    }

    func surrender() async {
        await endGame()
    }

    private func startRound() async {
        game.roundCount += 1

        /// Ось це ЛОГІЧНО неправильно, але вирішити не можу поки що.
        game.currentPlayer = (game.roundCount % 2 == 0) ? game.firstPlayer : game.opponent

        if !game.player.canPlay {
            game.player.passRound()
        }
        if !game.bot.canPlay {
            game.bot.passRound()
        }

        if game.player.isPassed && game.bot.isPassed {
            return await endRound()
        }
        if let currentPlayer = game.currentPlayer, currentPlayer.isPassed {
            /// Трохи вище, ми робимо player.isPassed, bot.isPassed, якщо вже немає карт для ходу.
            /// Якщо гравець, який зараз буде ходити, немає більше карток, тобто пасанув, то передаємо хід іншому
            /// гравцю.
            game.currentPlayer = game.opponent
        }

        await game.ui.showNotification(.roundStarted)
        await startTurn()
    }

    private func endRound() async {
        await declareResult()

        game.weathers.removeAll()

        if game.player.health == 0 || game.bot.health == 0 {
            await endGame()
        } else {
            await startRound()
        }
    }

    func passRound() async {
        game.currentPlayer?.passRound()

        await endTurn()
    }

    private func startTurn() async {
        guard let opponent = game.opponent else {
            return
        }

        if !opponent.isPassed {
            game.currentPlayer = opponent

            try? await Task.sleep(for: .seconds(0.5)) // ?????

            await game.ui.showNotification(game.currentPlayer!.isBot ? .turnOp : .turnMe)
        }

        if let currentPlayer = game.currentPlayer, currentPlayer.isBot {
            /// game.ai.startTurn()
            await game.aiStrategy.startTurn()
//            await startBotTurn()
        }
    }

    func endTurn() async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }
        if !currentPlayer.isPassed && !currentPlayer.canPlay {
            currentPlayer.passRound()
        }

        if currentPlayer.isPassed {
            await game.ui.showNotification(currentPlayer.isBot ? .roundPassedOp : .roundPassedMe)
        }

        if game.player.isPassed && game.bot.isPassed {
            await endRound()
        } else {
            await startTurn()
        }
    }
}

// MARK: Helpers
private extension GameFlow {
    func flipCoin() async {
        game.firstPlayer = Int.random(in: 0 ... 1) == 0 ? game.player : game.bot
        game.currentPlayer = game.firstPlayer
        await game.ui.showNotification(game.firstPlayer!.isBot ? .coinOp : .coinMe)
    }

    func declareResult() async {
        if game.leadingPlayer == nil {
            await game.ui.showNotification(.roundDraw)
        } else if game.leadingPlayer!.isBot {
            await game.ui.showNotification(.roundLose)
        } else {
            await game.ui.showNotification(.roundWin)
        }

        game.player.endRound(isWin: game.leadingPlayer != nil && !game.leadingPlayer!.isBot)
        game.bot.endRound(isWin: game.leadingPlayer != nil && game.leadingPlayer!.isBot)
    }

    func reset() {}
}
