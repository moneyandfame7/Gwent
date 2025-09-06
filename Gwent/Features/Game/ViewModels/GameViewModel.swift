//
//  GameViewModel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import Observation
import SwiftUI

// TODO: переробити щоб currentPlayer НІКОЛИ не був nil ???? ( в init викликати startGame )
// в кінці гри якщо робити restart - то reset стейту і заново викликати startGame

@Observable
final class GameViewModel {
    static let preview = GameViewModel(deck: .sample1)

    var player: Player
    var bot: Player

    /// Game Services
    var ui = GameUI()

    var settings = GameSettings.shared

    private var flow: GameFlow!

    private var cardActions: CardActions!

    private(set) var aiStrategy: GameAI!

    /// Players, based on game progress.
    var firstPlayer: Player?

    var currentPlayer: Player?

    var leadingPlayer: Player? {
        if player.totalScore > bot.totalScore {
            return player
        } else if player.totalScore < bot.totalScore {
            return bot
        }

        return nil
    }

    var opponent: Player? {
        guard let currentPlayer else {
            return nil
        }
        return currentPlayer.isBot ? player : bot
    }

    var weathers: [Card] = [] {
        didSet {
            if weathers.isEmpty {
                player.clearWeathers()
                bot.clearWeathers()
            } else {
                weathers.forEach { card in
                    player.applyWeather(card.weather!)
                    bot.applyWeather(card.weather!)
                }
            }
        }
    }

    var isGameOver = false

    var roundCount = 0

    /// Observation ignore ????]
    @ObservationIgnored
    var roundHistory: [Round] = []

    init(deck: Deck) {
        player = Player(deck: deck)
        bot = Player()

        cardActions = CardActions(game: self)
        flow = GameFlow(game: self)
        aiStrategy = GameAI(game: self)

        /// Init players:
        ///         1: Init leaders abilities
        ///         2. Init faction abilities

        print("✅ GameViewModel - Init -")
    }

    deinit {
        print("‼️ GameViewModel - Deinit -")
    }

    func startGame() {
        flow.startGame()
    }

    func isLeaderAvailable(player: Player) -> Bool {
        return cardActions.isLeaderAvailable(player: player)
    }

    func restartGame() {
        flow.restartGame()
    }
    
    func forfeitGame() {
        flow.surrender()
    }

    func endGame() {
        flow.endGame()
    }

    func playCard(_ card: Card, rowType: Card.Row? = nil, from container: CardContainer = .hand) async {
        await cardActions.play(card, rowType: rowType, from: container)
    }

    func playDecoy(_ decoy: Card, target: Card, rowType: Card.Row) async {
        await cardActions.playDecoy(decoy, target: target, rowType: rowType)
    }

    func endTurn() async {
        await flow.endTurn()
    }

    func passRound() async {
        await flow.passRound()
    }

    func getOpponent(for player: Player) -> Player {
        return player.isBot ? self.player : bot
    }

    func getPlayer(_ tag: Tag) -> Player {
        return tag == .bot ? bot : player
    }
}
