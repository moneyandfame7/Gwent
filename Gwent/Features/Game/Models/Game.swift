//
//  Game.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.01.2024.
//

import Foundation

struct Game {
    /// Players data.
    let player: Player

    let bot: Player

    var opponent: Player? {
        guard let currentPlayer else {
            return nil
        }
        return currentPlayer.isBot ? player : bot
    }

    var leadingPlayer: Player? {
        if player.totalScore > bot.totalScore {
            return player
        } else if player.totalScore < bot.totalScore {
            return bot
        }

        return nil
    }

    var currentPlayer: Player?

    var firstPlayer: Player?

    var weathers: [Card] = [] {
        didSet {
            weathersDidSet()
        }
    }

    var isOver = false

    var roundCount = 0

    var roundHistory: [Round] = []

    init(deck: Deck) {
        player = Player(deck: deck)
        bot = Player()
    }

    private func weathersDidSet() {
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
