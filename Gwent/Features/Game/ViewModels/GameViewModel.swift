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

    let player: Player
    let bot: Player

    /// Game Services
    var ui = GameUI()
    
    let settings = GameSettings()

    private var flow: GameFlow!
    
    private var cardActions: CardActions!
    
    private(set) var aiStrategy: GameAI!

    /// Players, based on game progress.
    var firstPlayer: Player?
    
    var currentPlayer: Player? {
        didSet {
            if let currentPlayer {
                ui.isDisabled = currentPlayer.isBot
            }
        }
    }

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
    
    var roundHistory: [Any] = []

    init(deck: Deck) {
        player = Player(deck: deck)
        bot = Player()

        cardActions = CardActions(game: self)
        flow = GameFlow(game: self)
        aiStrategy = GameAI(game: self)

        print("✅ GameViewModel - Init -")
    }

    deinit {
        print("‼️ GameViewModel - Deinit -")
    }

    func startGame() async {
        await flow.startGame()
    }

    func restartGame() {
        flow.restartGame()
    }

    func endGame() async {
        await flow.endGame()
    }

    func playCard(_ card: Card, rowType: Card.Row? = nil, from container: CardContainer = .hand) async {
        await cardActions.play(card, rowType: rowType, from: container)
    }

    func endTurn() async {
        await flow.endTurn()
    }

    func passRound() async {
        await flow.passRound()
    }
}
