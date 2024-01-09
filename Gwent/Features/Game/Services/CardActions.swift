//
//  CardActions.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 08.01.2024.
//

import SwiftUI

final class CardActions {
    private unowned var game: GameViewModel

    init(game: GameViewModel) {
        self.game = game
        print("✅ CardActions - Init - ")
    }

    deinit {
        print("‼️ CardActions - Deinit -")
    }

    // TODO: CardContainer -> Card.Container ???
    @MainActor
    func play(_ card: Card, rowType: Card.Row? = nil, from container: CardContainer) async {
        // ability - if game.currentPlayer.isAI - game.ai.ability(...)
        let destination = rowType ?? (card.combatRow == .agile ? .close : card.combatRow)

        guard let currentPlayer = game.currentPlayer else {
            return
        }

        game.ui.selectedCard = nil

        if card.weather != nil {
            await playWeather(card, from: container)

        } else if card.ability != nil, let destination {
            return await playWithAbility(card, rowType: destination, from: container)

        } else if let destination {
            currentPlayer.moveCard(card, rowType: destination, from: container)
        }

        try? await Task.sleep(for: .seconds(1))
        await game.endTurn()
    }

    private func playWithAbility(_ card: Card, rowType: Card.Row, from container: CardContainer) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }

        if card.ability == .commanderHorn && card.type == .special {
            Task(priority: .background) { // TODO: remove to CardView
                SoundManager.shared.playSound2(sound: .horn)
            }

            currentPlayer.applyHorn(card, row: rowType)
        } else if card.ability == .spy {
            await applySpy(card, rowType: rowType, from: container)

        } else {
            currentPlayer.moveCard(card, rowType: rowType, from: container)
            if card.ability == .tightBond {
                currentPlayer.applyTightBond(card, rowType: rowType)

            } else if card.ability == .moraleBoost {
                currentPlayer.applyMoraleBoost(card, rowType: rowType)

            } else if card.ability == .medic {
                try? await Task.sleep(for: .seconds(2))
                return await applyMedic(card)
            }
        }

        await game.endTurn()
    }
}

// MARK: Abilities

private extension CardActions {
    func applySpy(_ card: Card, rowType: Card.Row, from container: CardContainer) async {
        guard let currentPlayer = game.currentPlayer, let opponent = game.opponent else {
            return
        }
        guard let rowIndex = opponent.rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }

        withAnimation(.smooth(duration: 0.3)) {
            currentPlayer.removeFromContainer(card: card, container)
            // можливо можна зробити щось типу holderIs...
            // тут є трабли з анімацією, бо в рядках опонента інший неймспейс стоїть. я хз щшо робити, поки що забʼю
            // болт
            opponent.rows[rowIndex].addCard(card)
        }

        try? await Task.sleep(for: .seconds(0.5))

        for _ in 0 ..< 2 {
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.smooth(duration: 0.3)) {
                currentPlayer.drawCard(randomHandPosition: true)
            }
        }
    }

    func applyScorch(_ card: Card, rowType: Card.Row) async {}

    func applyMedic(_ card: Card) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }
        let units = currentPlayer.discard.filter { $0.type != .special && $0.type != .hero }

        if units.count <= 0 {
            return
        }

        if currentPlayer.isBot {
            Task {
                // TODO: aiStrategy.medic(units)
                let randomCard = units.randomElement()!
                await processMedic(resurrectionCard: randomCard)
            }

        } else {
            game.ui.showCarousel(Carousel(
                cards: units,
                count: 1,
                // TODO: TEST WITHOUT UNOWNED!!!!!!!!!!!!!!!
                action: { [unowned self] selectedCard in
                    Task {
                        game.ui.carousel = nil
                        await processMedic(resurrectionCard: selectedCard)
                    }
                }
            ))
        }
    }

    func processMedic(resurrectionCard: Card) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }
        currentPlayer.removeFromContainer(card: resurrectionCard, .discard)
        currentPlayer.addToContainer(card: resurrectionCard, .discard)

        let topDiscardIndex = currentPlayer.discard.endIndex - 1

        currentPlayer.discard[topDiscardIndex].animateAs = .medic

        try? await Task.sleep(for: .seconds(2))

        currentPlayer.discard[topDiscardIndex].animateAs = nil

        try? await Task.sleep(for: .seconds(0.2))

        /// тут взагалі можливо треба давати можливість юзеру обирати рядок, але це пізніше можливо..
        /// ( якщо так, то треба selectedCard перероблювати і то піздець )
        await play(resurrectionCard, from: .discard)
    }

    /// Це можна перенести до самого Player класу, бо не потрібно нічого від Game знати
    func applyMuster(_ card: Card, rowType: Card.Row) async {}
}

// MARK: Weathers

private extension CardActions {
    func playWeather(_ card: Card, from container: CardContainer) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }

        // MARK: - Clear Weather

        if card.weather == .clearWeather {
            moveToWeathers(card, from: container)

            let filtered = game.weathers.filter { $0.weather != .clearWeather }

            /// Remove all other weathers
            withAnimation {
                for card in filtered {
                    guard let index = game.weathers.firstIndex(where: { $0.id == card.id }) else {
                        return
                    }
                    moveWeatherToDiscard(at: index)
                }
            }

            try? await Task.sleep(for: .seconds(2))

            /// Remove Clear Weather card.
            withAnimation(.smooth(duration: 1)) {
                moveWeatherToDiscard(at: 0)
            }
        } else {
            // MARK: - Common weather ( except Clear Weather )

            let sameWeatherIndex = game.weathers
                .firstIndex(where: { ($0.id == card.id) || ($0.weather == card.weather) })

            if let sameWeatherIndex {
                withAnimation(.smooth(duration: 0.3)) {
                    moveWeatherToDiscard(at: sameWeatherIndex)
                }
                try? await Task.sleep(for: .seconds(0.55))
            }

            moveToWeathers(card, from: container)
        }
    }

    func moveToWeathers(_ card: Card, from container: CardContainer) {
        guard let currentPlayer = game.currentPlayer, let weather = card.weather else {
            return
        }

        let soundName = Card.getSoundAsset(weather: weather)

        Task(priority: .background) {
            SoundManager.shared.playSound(sound: soundName)
        }
        var copy = card
        copy.holderIsBot = currentPlayer.isBot

        withAnimation {
            currentPlayer.removeFromContainer(card: card, container)
            game.weathers.append(copy)
        }
    }

    func moveWeatherToDiscard(at index: [Card].Index) {
        let removed = game.weathers.remove(at: index)

        // TODO: in GameViewModel add these function?
        let holder = removed.holderIsBot! ? game.bot : game.player

        holder.moveToDiscard(removed)
    }
}
