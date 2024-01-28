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

        print("✅ GameFlow - Init -")
    }

    deinit {
        print("‼️ GameFlow - Deinit -")
    }

    func startGame() {
        defineFirstPlayer { [unowned self] player, notification in
            game.firstPlayer = player

            if game.player.leader.leaderAbility == .cancelLeaderAbility {
                game.bot.isLeaderAvailable = false
            }
            if game.bot.leader.leaderAbility == .cancelLeaderAbility {
                game.player.isLeaderAvailable = false
            }

            Task {
                await game.ui.showNotification(notification)

                await dealCards()

                withAnimation(.smooth(duration: 0.3)) {
                    self.initialRedraw()
                }
            }
        }
    }

    func restartGame() {
        reset()

        startGame()
    }

    func endGame() {
        while game.roundHistory.count < 3 {
            game.roundHistory.append(
                Round(winner: nil, scoreMe: 0, scoreAI: 0)
            )
        }
        withAnimation {
            game.isGameOver = true
        }
    }

    func surrender() {
        // TODO: переробити, тут має бути якось інакше.

        let currentRound = Round(
            winner: game.leadingPlayer,
            scoreMe: game.player.totalScore,
            scoreAI: game.bot.totalScore
        )
        if game.roundHistory.isEmpty {
            game.roundHistory.append(currentRound)
        } else {
            game.roundHistory[game.roundHistory.safeLastIndex] = currentRound
        }

        while game.roundHistory.count < 3 {
            game.roundHistory.append(
                Round(winner: game.bot, scoreMe: 0, scoreAI: 0)
            )
        }

        endGame()
    }

    @MainActor
    private func startRound() async {
        game.roundCount += 1

        print("IDS BOT: \(game.bot.hand.map { $0.id })")
        print("IDS ME: \(game.player.hand.map { $0.id })")

        print("PlayerN: \(game.ui.namespaces.playerCards)")
        print("BotN: \(game.ui.namespaces.botCards)")
        /// Ось це ЛОГІЧНО неправильно, але вирішити не можу поки що.

        game.currentPlayer = (game.roundCount % 2 == 0) ? game.firstPlayer : game.getOpponent(for: game.firstPlayer!)

        // MARK: #FactionAbility - Northern Realms

        if let prevRound = game.roundHistory.last, let prevRoundWinner = prevRound.winner {
            if prevRoundWinner.deck.faction == .northern {
                withAnimation(.card) {
                    prevRoundWinner.drawCard()
                }
                await game.ui.showNotification(.northern)
            }
        }

        // MARK: #FactionAbility - Monsters

        if game.player.deck.faction == .monsters && game.player.rows.contains(where: { $0.cards.count > 0 }) {
            await game.ui.showNotification(.monsters)
        }
        if game.bot.deck.faction == .monsters && game.bot.rows.contains(where: { $0.cards.count > 0 }) {
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

    @MainActor
    func passRound() async {
        game.ui.selectedCard = nil
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

    @MainActor
    private func startTurn() async {
        guard let opponent = game.opponent else {
            return
        }

        game.ui.isTurnHighlightDisabled = false
        if !opponent.isPassed {
            game.currentPlayer = opponent

            await game.ui.showNotification(game.currentPlayer!.isBot ? .turnOp : .turnMe)
        }

        guard let currentPlayer = game.currentPlayer else {
            return
        }

        if currentPlayer.isBot {
            game.ui.isDisabled = true
            await game.aiStrategy.startTurn()
        } else {
            game.ui.isDisabled = false
        }
    }

    func endTurn() async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }
        game.ui.isTurnHighlightDisabled = true

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
    @MainActor
    func flipCoin() async {
        game.firstPlayer = Int.random(in: 0 ... 1) == 0 ? game.player : game.bot
        game.currentPlayer = game.firstPlayer
        await game.ui.showNotification(game.firstPlayer!.isBot ? .coinOp : .coinMe)
    }

    @MainActor
    func dealCards() async {
        SoundManager.shared.playSound(sound: .deck)

        // TODO: move to dealCards
        for _ in 0 ..< 10 {
            /// Delay between drawing 1 card.
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.smooth(duration: 0.3)) {
                self.game.player.drawCard(randomDeckPosition: false)
                self.game.bot.drawCard(randomDeckPosition: false)
            }
        }
        if game.player.deck.leader.leaderAbility == .drawExtraCard {
            withAnimation(.smooth(duration: 0.3)) {
                self.game.player.drawCard(randomDeckPosition: false)
            }
        }
        if game.bot.deck.leader.leaderAbility == .drawExtraCard {
            withAnimation(.smooth(duration: 0.3)) {
                self.game.bot.drawCard(randomDeckPosition: false)
            }
        }
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

                    guard let index = game.ui.carousel!.cards.firstIndex(where: { $0.id == card.id }) else {
                        return
                    }

                    game.ui.carousel!.cards.remove(at: index)
                    game.ui.carousel!.cards.insert(random, at: index)

                    /// Move selected card to deck.
                    game.player.swapContainers(card, from: .hand, to: .deck)

                    /// Move random card to hand.
                    game.player.removeFromContainer(card: random, .deck)
                    game.player.insertToContainer(random, .hand, at: index)

                },
                completion: { [unowned self] in
                    Task {
                        /// Delay before showing the ".roundStart" notification
                        try? await Task.sleep(for: .seconds(0.4))

                        await startRound()
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
            if isMeNilf == isBotNilf {
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

    func reset() {
        game.roundHistory = []
        game.roundCount = 0
        game.weathers = []
        game.firstPlayer = nil
        game.currentPlayer = nil
        game.isGameOver = false
        game.player.reset()
        game.bot.reset()
    }

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

        if isBotScoiatael == isPlayerScoiatael {
            completion(firstPlayer, firstPlayer.isBot ? .coinOp : .coinMe)

        } else if isBotScoiatael {
            completion(firstPlayer, firstPlayer.isBot ? .scoiatael : .coinMe)

        } else if isPlayerScoiatael {
            let alert = AlertItem(
                title: "Would you like to go first",
                description: "The Scoia'tael faction perk allows you to decide who will get to go first",
                cancelButton: ("Let Opponent Start", { [unowned self] in
                    completion(game.bot, .coinOp)
                }),
                confirmButton: ("Go First", { [unowned self] in
                    completion(game.player, .coinMe)
                })
            )

            game.ui.showAlert(alert)
        }
    }
}
