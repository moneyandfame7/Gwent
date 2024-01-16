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

    func startGame() {
        defineFirstPlayer { player, notification in
            self.game.firstPlayer = player
            self.game.currentPlayer = player

            Task { @MainActor in
//                try? await Task.sleep(for: .seconds(0.5))

                await self.game.ui.showNotification(notification)

                SoundManager.shared.playSound(sound: .deck)

                for _ in 0 ..< 10 {
                    /// Delay between drawing 1 card.
                    try? await Task.sleep(for: .seconds(0.1))
                    withAnimation(.smooth(duration: 0.3)) {
                        self.game.player.drawCard()
                        self.game.bot.drawCard()
                    }
                }

                withAnimation(.smooth(duration: 1)) {
                    self.initialRedraw()
                }
            }
        }
    }

    func restartGame() {}

    func endGame() {
        withAnimation {
            game.isGameOver = true
        }
    }

    func surrender() async {
        await endGame()
    }

    @MainActor
    private func startRound() async {
        game.roundCount += 1

        /// Ось це ЛОГІЧНО неправильно, але вирішити не можу поки що.
        game.currentPlayer = (game.roundCount % 2 == 0) ? game.firstPlayer : game.opponent

        // MARK: #FactionAbility - Northern Realms

        if let prevRound = game.roundHistory.last, let prevRoundWinner = prevRound.winner {
            if prevRoundWinner.deck.faction == .northern {
                prevRoundWinner.drawCard()
                await game.ui.showNotification(.northern)
            }
        }

        // MARK: #FactionAbility - Monsters

        if game.player.deck.faction == .monsters && game.player.rows.contains(where: { $0.cards.count > 0 }) {
            print("Monsters Ability Triggered PLAYER")
            await game.ui.showNotification(.monsters)
        }
        if game.bot.deck.faction == .monsters && game.bot.rows.contains(where: { $0.cards.count > 0 }) {
            print("Monsters Ability Trigered BOT")
            await game.ui.showNotification(.monsters)
        }

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

//        try? await Task.sleep(for: .seconds(0.5))

        // TODO: переробити, тут треба віддавати в відбій до певного юзера картки
        clearWeathers()

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

    private func clearWeathers() {
        let weathers = game.weathers

        for weather in weathers {
            guard let holderIsBot = weather.holderIsBot else {
                continue
            }

            let holder = holderIsBot ? game.bot : game.player

            game.weathers.removeAll(where: { $0.id == weather.id })
            holder.discard.append(weather)
        }
        /// Clear weathers
        /// If monsters - random card
        /// Clear rows
        ///
    }

    private func startTurn() async {
        guard let opponent = game.opponent else {
            return
        }

        if !opponent.isPassed {
            game.currentPlayer = opponent

            await game.ui.showNotification(game.currentPlayer!.isBot ? .turnOp : .turnMe)
        }

        guard let currentPlayer = game.currentPlayer else {
            return
        }

        if currentPlayer.isBot {
            await game.aiStrategy.startTurn()
        } else {
            game.ui.isDisabled = false
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

        try? await Task.sleep(for: .seconds(1))

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

    func initialRedraw() {
        /// Bot redraw
        game.aiStrategy.initialRedraw()

        /// Player redraw
        game.ui.showCarousel(
            Carousel(
                cards: game.player.hand,
                count: 2,
                title: "Choose a card to redraw",
                cancelButton: "Finish redrawing",
                onSelect: { [unowned self] card in
                    let random = game.player.deck.cards.randomElement()!
                    withAnimation(.smooth(duration: 0.3)) {
                        guard let index = game.ui.carousel!.cards.firstIndex(where: { $0.id == card.id }) else {
                            return
                        }

                        game.ui.carousel!.cards.remove(at: index)
                        game.ui.carousel!.cards.insert(random, at: index)

                        game.player.removeFromContainer(card: card, .hand)
                        game.player.addToContainer(card: card, .deck)

                        game.player.removeFromContainer(card: random, .deck)
                        game.player.addToContainer(card: random, .hand)
                    }
                },
                completion: {
                    Task {
                        /// Delay before showing the ".roundStart" notification
                        try? await Task.sleep(for: .seconds(0.4))

                        await self.startRound()
                    }
                }
            )
        )
    }

    func declareResult() async {
        // MARK: #FactionAbility - Nilfgaardian Empire

        let isMeNilf = game.player.deck.faction == .nilfgaard
        let isBotNilf = game.bot.deck.faction == .nilfgaard

        var isBotWin = false
        var isMeWin = false

        if game.leadingPlayer == nil {
            if isMeNilf && isBotNilf {
                await game.ui.showNotification(.roundDraw)
            } else if isMeNilf {
                await game.ui.showNotification(.nilfgaard)
                await game.ui.showNotification(.roundWin)
                isMeWin = true
            } else {
                await game.ui.showNotification(.nilfgaard)
                await game.ui.showNotification(.roundLose)
                isBotWin = true
            }

        } else if game.leadingPlayer!.isBot {
            await game.ui.showNotification(.roundLose)
            isBotWin = true
        } else {
            await game.ui.showNotification(.roundWin)
            isMeWin = true
        }

        game.roundHistory.append(
            Round(
                winner: isMeWin ? game.player : isBotWin ? game.bot : nil,
                scoreMe: game.player.totalScore,
                scoreAI: game.bot.totalScore
            )
        )

        game.player.endRound(isWin: isMeWin)
        game.bot.endRound(isWin: isBotWin)
    }

    func reset() {}

    func initGame() {
        if game.player.leader.leaderAbility == .cancelLeaderAbility {
            game.bot.isLeaderAvailable = false
        }
        if game.bot.leader.leaderAbility == .cancelLeaderAbility {
            game.player.isLeaderAvailable = false
        }
    }

    // MARK: #FactionAbility - Scoiatael

    func defineFirstPlayer(completion: @escaping (Player, Notification) -> Void) {
        let isBotScoiatael = game.bot.deck.faction == .scoiatael
        let isPlayerScoiatael = game.player.deck.faction == .scoiatael

        let firstPlayer = Int.random(in: 0 ... 1) == 0 ? game.bot : game.player

        if isBotScoiatael && isPlayerScoiatael || (!isBotScoiatael && !isPlayerScoiatael) {
            completion(firstPlayer, firstPlayer.isBot ? .coinOp : .coinMe)

        } else if isBotScoiatael {
            completion(firstPlayer, firstPlayer.isBot ? .scoiatael : .coinMe)

        } else if isPlayerScoiatael {
            game.ui.showAlert(
                AlertItem(
                    title: "Would you like to go first",
                    description: "The Scoia'tael faction perk allows you to decide who will get to go first",
                    cancelButton: ("Let Opponent Start", {
                        completion(self.game.bot, .coinOp)
                    }),
                    confirmButton: ("Go First", {
                        completion(self.game.player, .coinMe)
                    })
                )
            )
        }
    }
}
