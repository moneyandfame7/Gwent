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
        // ability - if game.currentPlayer.isAI - game.ai.ability(...) - обирати там де найбільша сила рядку
        let destination = rowType ?? (card.combatRow == .agile ? .close : card.combatRow)

        guard let currentPlayer = game.currentPlayer else {
            return
        }

        game.ui.selectedCard = nil

        if card.weather != nil {
            await playWeather(card, from: container)

        } else if card.type == .special && card.ability == .scorch {
            await playScorch(card)

        } else if card.ability != nil, let destination {
            return await playWithAbility(card, rowType: destination, from: container)

        } else if let destination {
            currentPlayer.moveCard(card, from: container, to: destination)
        }

        /// Safe delay before the ending turn and showing notification
        try? await Task.sleep(for: .seconds(1))
        await game.endTurn()
    }

    private func playWithAbility(_ card: Card, rowType: Card.Row, from container: CardContainer) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }

        if card.ability == .commanderHorn && card.type == .special {
            currentPlayer.applyHorn(card, row: rowType)

//            try? await Task.sleep(for: .seconds(0.3))
            SoundManager.shared.playSound(sound: .horn)

        } else if card.ability == .spy {
            await applySpy(card, rowType: rowType, from: container)

        } else {
            currentPlayer.moveCard(card, from: container, to: rowType)

            if card.ability == .tightBond {
                SoundManager.shared.playSound(sound: .tightBond)

                currentPlayer.applyTightBond(card, rowType: rowType)

            } else if card.ability == .muster {
                await currentPlayer.applyMuster(card, rowType: rowType)

            } else if card.ability == .moraleBoost {
                currentPlayer.applyMoraleBoost(card, rowType: rowType)

            } else if card.ability == .medic {
                /// Delay before using the medic ability ( showing carousel ).
                try? await Task.sleep(for: .seconds(2))
                return await applyMedic(card)
            }
        }

        /// Safe delay before the ending turn and showing notification
        try? await Task.sleep(for: .seconds(1))
        await game.endTurn()
    }
}

// MARK: Abilities

private extension CardActions {
    @MainActor
    func playScorch(_ card: Card, rowType: Card.Row? = nil) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }
        guard let opponent = game.opponent else {
            return
        }

        let maxPower = (currentPlayer.rows + opponent.rows)
            .flatMap { $0.cards.compactMap { $0.editedPower ?? $0.power } }
            .max()

        guard let maxPower, maxPower > 0 else {
            return
        }

        withAnimation(.smooth(duration: 0.7)) {
            currentPlayer.removeFromContainer(card: card, .hand)
            currentPlayer.addToContainer(card: card, .discard)
        }

        print("Max: \(maxPower)")

        /// Find targets
        var opponentScorch: [Card.Row: [Card]] = [:]
        for row in opponent.rows {
            let shouldScorch = row.cards.filter { $0.type != .hero && $0.availablePower == maxPower }
            if shouldScorch.isEmpty {
                continue
            }
            opponentScorch[row.type] = shouldScorch
        }
        var currentPlayerScorch: [Card.Row: [Card]] = [:]
        for row in currentPlayer.rows {
            let shouldScorch = row.cards.filter { $0.type != .hero && $0.availablePower == maxPower }
            if shouldScorch.isEmpty {
                continue
            }
            currentPlayerScorch[row.type] = shouldScorch
        }

        SoundManager.shared.playSound(sound: .scorch)
        /// Animate scorch for target cards
        await withTaskGroup(of: Void.self) { group in
//            group.addTask {
//                await SoundManager.shared.playSound(sound: .scorch)
//            }

            for (row, cards) in opponentScorch {
                for card in cards {
                    group.addTask {
                        await opponent.animateInContainer(card: card, as: .scorch, .row(row))
                    }
                }
            }

            for (row, cards) in currentPlayerScorch {
                for card in cards {
                    group.addTask {
                        await currentPlayer.animateInContainer(card: card, as: .scorch, .row(row))
                    }
                }
            }
        }

        /// Delete target cards
        for (row, cards) in opponentScorch {
            for card in cards {
                withAnimation(.smooth(duration: 0.3)) {
                    opponent.removeFromContainer(card: card, .row(row))
                    opponent.addToContainer(card: card, .discard)
                }
            }
        }
        for (row, cards) in currentPlayerScorch {
            for card in cards {
                withAnimation(.smooth(duration: 0.3)) {
                    currentPlayer.removeFromContainer(card: card, .row(row))
                    currentPlayer.addToContainer(card: card, .discard)
                }
            }
        }
    }

    func applySpy(_ card: Card, rowType: Card.Row, from container: CardContainer) async {
        guard let currentPlayer = game.currentPlayer, let opponent = game.opponent else {
            return
        }
        guard let rowIndex = opponent.rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }
        SoundManager.shared.playSound(sound: .spy)
        withAnimation(.smooth(duration: 0.3)) {
            currentPlayer.removeFromContainer(card: card, container)
            // можливо можна зробити щось типу holderIs...
            // тут є трабли з анімацією, бо в рядках опонента інший неймспейс стоїть. я хз щшо робити, поки що забʼю
            // болт
            opponent.rows[rowIndex].addCard(card)
        }

        await withTaskGroup(of: Void.self) { group in
//            group.addTask {
//                await SoundManager.shared.playSound(sound: .spy)
//            }
            group.addTask {
                await opponent.animateInContainer(card: card, .row(rowType))
            }
        }

        for _ in 0 ..< 2 {
            /// Delay between the drawing 1 card.
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.smooth(duration: 0.3)) {
                SoundManager.shared.playSound(sound: .drawCard)

                currentPlayer.drawCard(randomHandPosition: true)
            }
        }
    }

    func applyMedic(_ card: Card) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }
        let units = currentPlayer.discard.filter { $0.type != .special && $0.type != .hero }

        if units.count <= 0 {
            return await game.endTurn()
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
                title: "Pick a card to restore",
                // TODO: TEST WITHOUT UNOWNED!!!!!!!!!!!!!!!
                onSelect: { [unowned self] selectedCard in
                    Task {
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
        /// Move card to top of the discard.
        currentPlayer.removeFromContainer(card: resurrectionCard, .discard)
        currentPlayer.addToContainer(card: resurrectionCard, .discard)

        let topDiscardIndex = currentPlayer.discard.endIndex - 1
        SoundManager.shared.playSound(sound: .medic)
        await withTaskGroup(of: Void.self) { group in
//            group.addTask {
//                await SoundManager.shared.playSound(sound: .medic)
//            }

            group.addTask {
                currentPlayer.discard[topDiscardIndex].animateAs = .medic

                try? await Task.sleep(for: .seconds(2))

                currentPlayer.discard[topDiscardIndex].animateAs = nil

//                try? await Task.sleep(for: .seconds(0.2))
            }
        }

        /// тут взагалі можливо треба давати можливість юзеру обирати рядок, але це пізніше можливо..
        /// ( якщо так, то треба selectedCard перероблювати і то піздець )
        await play(resurrectionCard, from: .discard)
    }
}

// MARK: Weathers

private extension CardActions {
    func playWeather(_ card: Card, from container: CardContainer) async {
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
        SoundManager.shared.playSound(sound: soundName)
//        Task {
//            await SoundManager.shared.playSound(sound: soundName)
//        }
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

        holder.addToContainer(card: removed, .discard)
    }
}

// MARK: Leader abilities

private extension CardActions {
    func playLeader(_ card: Card) async {
        guard let ability = card.leaderAbility else {
            return
        }
        switch ability {
        // MARK: Nilfgaard leaders

        /// ID: #57
        case .look3Cards:
            await applyLook3Cards(card)
        /// ID #58
        case .pickTorrentialRain:
            await applyPickTorrentialRain(card)
        /// ID: #59
        case .drawFromDiscardPile:
            await applyDrawFromOpponentDiscard(card)
        /// ID: #60
        case .cancelLeaderAbility:
            await applyDisableLeaderAbility(card)

        // MARK: Monster leaders

        /// ID: #64
        case .restoreFromDiscardPile:
            await applyDrawFromDiscard(card)
        /// ID: #65
        case .doubleCloseCombatPower:
            await applyDoubleClosePower(card)
        /// ID: #66
        case .discardAndDrawCards:
            await applyDiscardAndDraw(card)
        /// ID: #67
        case .pickWeatherAndPlay:
            await applyPickWeatherAndPlay(card)

        // MARK: Northern leaders

        /// ID: #75
        case .pickFogAndPlay:
            await applyPickFogAndPlay(card)
        /// ID: #76
        case .clearWeather:
            await applyClearWeather(card)
        /// ID: #77
        case .doubleSiegePower:
            await applyDoubleSiegePower(card)
        /// ID: #78
        case .destroyStrongestSiege:
            await applyDestroyStrongestSiege(card)

        // MARK: Scoiatael leaders

        /// Handle on startGame
        /// ID: #80
        case .drawExtraCard:
            await applyDrawExtraCard(card)
        /// ID: #81
        case .pickFrostAndPlay:
            await applyPickFrostAndPlay(card)
        /// ID: #82
        case .destroyStrongestClose:
            await applyDestroyStrongestClose(card)
        /// ID: #83
        case .doubleRangedPower:
            await applyDoubleRangedPower(card)
        }
    }

    func applyLook3Cards(_ card: Card) async {
        guard let currentPlayer = game.currentPlayer, let opponent = game.opponent else {
            return
        }

        if currentPlayer.isBot {
            return
        }

        let cards = opponent.hand.randomElements(count: 3)

//        game.ui.showCarousel(
//            Carousel(cards: cards)
//        )
    }

    func applyPickTorrentialRain(_ card: Card) async {}
    func applyDrawFromOpponentDiscard(_ card: Card) async {}
    func applyDisableLeaderAbility(_ card: Card) async {}

    func applyDrawFromDiscard(_ card: Card) async {}
    func applyDoubleClosePower(_ card: Card) async {}
    func applyDiscardAndDraw(_ card: Card) async {}

    func applyPickWeatherAndPlay(_ card: Card) async {}
    func applyPickFogAndPlay(_ card: Card) async {}
    func applyClearWeather(_ card: Card) async {}
    func applyDoubleSiegePower(_ card: Card) async {}
    func applyDestroyStrongestSiege(_ card: Card) async {}

    func applyDrawExtraCard(_ card: Card) async {}
    func applyPickFrostAndPlay(_ card: Card) async {}
    func applyDestroyStrongestClose(_ card: Card) async {}
    func applyDoubleRangedPower(_ card: Card) async {}
}
