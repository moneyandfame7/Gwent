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

        guard let currentPlayer = game.currentPlayer, let opponent = game.opponent else {
            return
        }

        if !currentPlayer.isBot && !opponent.isPassed {
            game.ui.isDisabled = true
        }

        await game.ui.animateCardUsage(card, holder: currentPlayer.tag)

        if card.type == .leader {
            return await playLeader(card)
        } else if card.weather != nil {
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

    @MainActor
    func playDecoy(_ decoy: Card, target: Card, rowType: Card.Row) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }
        guard let decoyIndex = currentPlayer.hand.firstIndex(where: { $0.id == decoy.id }) else {
            return
        }

        guard let targetIndex = currentPlayer.getRow(rowType).cards.firstIndex(where: { $0.id == target.id }) else {
            return
        }
        game.ui.selectedCard = nil

        SoundManager.shared.playSound(sound: .decoy)
        withAnimation(.smooth(duration: 0.5)) {
            /// Add decoy
            currentPlayer.removeFromContainer(at: decoyIndex, .hand)
            currentPlayer.insertToContainer(decoy, .row(rowType), at: targetIndex)

            /// Remove target card
            currentPlayer.removeFromContainer(card: target, .row(rowType))
            currentPlayer.insertToContainer(target, .hand, at: decoyIndex)
        }

        try? await Task.sleep(for: .seconds(0.3))

        await game.endTurn()
    }

    func isLeaderAvailable(player: Player) -> Bool {
        guard let leaderAbility = player.deck.leader.leaderAbility else {
            return false
        }

        let opponent = game.getOpponent(for: player)

        switch leaderAbility {
        case .look3Cards:
            return !opponent.hand.isEmpty
        case .pickTorrentialRain:
            return true
        case .drawFromDiscardPile:
            return !opponent.discard.isEmpty

        case .restoreFromDiscardPile:
            return !player.discard.isEmpty
        case .doubleCloseCombatPower:
            return player.getRow(.close).horn == nil
        case .discardAndDrawCards:
            return player.hand.count >= 2 && player.deck.cards.count >= 1
        case .pickWeatherAndPlay:
            return true

        case .pickFogAndPlay, .clearWeather, .destroyStrongestSiege:
            return true
        case .doubleSiegePower:
            return player.getRow(.siege).horn == nil

        case .pickFrostAndPlay, .destroyStrongestClose:
            return true
        case .doubleRangedPower:
            return player.getRow(.ranged).horn == nil

        default: return false
        }
    }

    @MainActor
    private func playWithAbility(_ card: Card, rowType: Card.Row, from container: CardContainer) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }
        print("Ability thread", Thread.current.description)
        if card.ability == .commanderHorn && card.type == .special {
            await currentPlayer.playHorn(card, rowType: rowType)

        } else if card.ability == .spy {
            await applySpy(card, rowType: rowType, from: container)

        } else {
            currentPlayer.moveCard(card, from: container, to: rowType)

            if card.ability == .commanderHorn {
                await currentPlayer.applyHorn(card, rowType: rowType, from: container)

            } else if card.ability == .tightBond {
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
            .flatMap { $0.cards
                .filter { $0.type != .hero }
                .compactMap { $0.editedPower ?? $0.power }
            }
            .max()

        SoundManager.shared.playSound(sound: .scorch)

        withAnimation(.smooth(duration: 0.7)) {
            currentPlayer.removeFromContainer(card: card, .hand)
            currentPlayer.addToContainer(card: card, .discard)
        }

        guard let maxPower, maxPower > 0 else {
            return
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
        let units = currentPlayer.discard.filter { $0.type == .unit }

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

    @MainActor
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
    @MainActor
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
                // Можливо варто повернути затримку, треба тестити, якщо це картка повертається до бота, а не до мене.
                // якщо повертається до мене, то впринципі все ок працює.
//                try? await Task.sleep(for: .seconds(0.55))
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
            if !card.isCreatedByLeader {
                currentPlayer.removeFromContainer(card: card, container)
            }
            game.weathers.append(copy)
        }
    }

    func moveWeatherToDiscard(at index: [Card].Index) {
        let removed = game.weathers.remove(at: index)

        if removed.isCreatedByLeader {
            return
        }

        // TODO: in GameViewModel add these function?
        let holder = removed.holderIsBot! ? game.bot : game.player

        holder.addToContainer(card: removed, .discard)
    }
}

// MARK: Leader abilities

private extension CardActions {
    func playLeader(_ card: Card) async {
        guard let currentPlayer = game.currentPlayer,
              let ability = card.leaderAbility
        else {
            return
        }

        func completion() {
            Task {
                currentPlayer.isLeaderAvailable = false

                try? await Task.sleep(for: .seconds(1))

                await game.endTurn()
            }
        }

        switch ability {
        // MARK: Nilfgaard leaders

        /// ID: #58
        // With completion -> return
        case .look3Cards:
            return applyLook3Cards(card, completion: completion)
        /// ID #59
        case .pickTorrentialRain:
            await applyPickTorrentialRain(card)
        /// ID: #60
        // With completion -> return
        case .drawFromDiscardPile:
            return applyDrawFromOpponentDiscard(card, completion: completion)
        /// ID: #61 - is processed at the start of the game
//        case .cancelLeaderAbility:
//            await applyDisableLeaderAbility(card)

        // MARK: Monster leaders

        /// ID: #64
        // With completion -> return
        case .restoreFromDiscardPile:
            return applyDrawFromDiscard(card, completion: completion)
        /// ID: #65
        case .doubleCloseCombatPower:
            await applyDoubleClosePower(card)
        /// ID: #66
        // With completion -> return
        case .discardAndDrawCards:
            return applyDiscardAndDraw(card, completion: completion)
        /// ID: #67
        // With completion -> return
        case .pickWeatherAndPlay:
            return await applyPickWeatherAndPlay(card, completion: completion)

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

        /// ID: #80 - is processed at the start of the game
//        case .drawExtraCard:
//            await applyDrawExtraCard(card)
        /// ID: #81
        case .pickFrostAndPlay:
            await applyPickFrostAndPlay(card)
        /// ID: #82
        case .destroyStrongestClose:
            await applyDestroyStrongestClose(card)
        /// ID: #83
        case .doubleRangedPower:
            await applyDoubleRangedPower(card)
        default:
            print("default Leader case: ", card)
            return
        }

        completion()
    }

    func applyLook3Cards(_ card: Card, completion: @escaping () -> Void) {
        guard let currentPlayer = game.currentPlayer, let opponent = game.opponent else {
            return
        }

        if currentPlayer.isBot {
            return completion()
        }

        let cards = opponent.hand.randomElements(count: 3)

        let carousel = Carousel(
            cards: cards,
            title: "Look random opponent cards",
            cancelButton: "Hide",
            completion: completion
        )

        game.ui.showCarousel(carousel)
    }

    func applyPickTorrentialRain(_ card: Card) async {
        await processPickOneWeather(.torrentialRain)
    }

    func applyDrawFromOpponentDiscard(_ card: Card, completion: @escaping () -> Void) {
        guard let currentPlayer = game.currentPlayer, let opponent = game.opponent else {
            return
        }

        let cards = opponent.discard.filter { $0.type == .unit }

        if cards.isEmpty {
            print("Discard is empty")
            return completion()
        }

        if currentPlayer.isBot {
            // let card = game.aiStrategy.medic(cards: cards)
//            opponent.removeFromContainer(card: card, .discard)
//            currentPlayer.addToContainer(card: card, .hand)

            return completion()
        }

        let carousel = Carousel(
            cards: cards,
            count: 1,
            title: "Pick a card",
            onSelect: { card in
                opponent.removeFromContainer(card: card, .discard)
                currentPlayer.addToContainer(card: card, .hand)
            },
            completion: completion
        )

        game.ui.showCarousel(carousel)
    }

//    func applyDisableLeaderAbility(_ card: Card) async {}

    func applyDrawFromDiscard(_ card: Card, completion: @escaping () -> Void) {
        guard let currentPlayer = game.currentPlayer else {
            return
        }

        let cards = currentPlayer.discard.filter { $0.type == .unit }

        if cards.isEmpty {
            print("My Discard is empty")
            return completion()
        }

        if currentPlayer.isBot {
            // let card=           game.aiStrategy.medic(cards: cards)
//            currentPlayer.removeFromContainer(card: card, .discard)
//            currentPlayer.addToContainer(card: card, .hand)
            return completion()
        }

        let carousel = Carousel(
            cards: cards,
            count: 1,
            title: "Pick a card",
            onSelect: { card in
                withAnimation(.smooth(duration: 0.5)) {
                    currentPlayer.swapContainers(card, from: .discard, to: .hand)
                }
            },
            completion: completion
        )

        game.ui.showCarousel(carousel)
    }

    func applyDoubleClosePower(_ card: Card) async {
        await processDoublePower(rowType: .close)
    }

    func applyDiscardAndDraw(_ card: Card, completion: @escaping () -> Void) {
        guard let currentPlayer = game.currentPlayer else {
            return
        }

        let hand = currentPlayer.hand

        if hand.count < 2 {
            print("Current player hand size <2")
            return completion()
        }

        if currentPlayer.isBot {
            for _ in 0 ..< 2 {
                let randomToRemove = hand.randomElement()!

                currentPlayer.removeFromContainer(card: randomToRemove, .hand)
                currentPlayer.addToContainer(card: randomToRemove, .discard)
            }

            let randomToDraw = currentPlayer.deck.cards.randomElement()!

            currentPlayer.removeFromContainer(card: randomToDraw, .deck)
            currentPlayer.addToContainer(card: randomToDraw, .hand)

            return completion()
        }

        let carouselForDrawing = Carousel(
            cards: currentPlayer.deck.cards,
            title: "Choose a card to draw",
            onSelect: { card in
                currentPlayer.removeFromContainer(card: card, .deck)
                currentPlayer.addToContainer(card: card, .hand)
            },
            completion: completion
        )

        let carouselForDiscarding = Carousel(
            cards: hand,
            count: 2,
            title: "Choose a card to discard",
            onSelect: { [unowned self] card in
                guard let index = game.ui.carousel!.cards.firstIndex(where: { $0.id == card.id }) else {
                    return
                }

                game.ui.carousel!.cards.remove(at: index)

                currentPlayer.removeFromContainer(card: card, .hand)
                currentPlayer.addToContainer(card: card, .discard)
            },
            completion: { [unowned self] in
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.5))

                    game.ui.showCarousel(carouselForDrawing)
                }
            }
        )

        game.ui.showCarousel(carouselForDiscarding)
    }

    func applyPickWeatherAndPlay(_ card: Card, completion: @escaping () -> Void) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }

        let cards = currentPlayer.deck.cards.filter { $0.type == .weather }

        if cards.isEmpty {
            print("No weather cards in your deck.")
            return completion()
        }

        if currentPlayer.isBot {
            let random = cards.randomElement()!

            await playWeather(random, from: .deck)

            return completion()
        }

        let carousel = Carousel(
            cards: cards,
            title: "Pick a weather to play",
            onSelect: { [unowned self] card in
                Task {
                    await playWeather(card, from: .deck)
                }
            },
            completion: completion
        )

        game.ui.showCarousel(carousel)
    }

    func applyPickFogAndPlay(_ card: Card) async {
        await processPickOneWeather(.impenetrableFog)
    }

    func applyClearWeather(_ card: Card) async {
        var clearWeather = Card.all2[25]
        clearWeather.isCreatedByLeader = true
        clearWeather.id *= 123

        await playWeather(clearWeather, from: .deck)
    }

    func applyDoubleSiegePower(_ card: Card) async {
        await processDoublePower(rowType: .siege)
    }

    func applyDestroyStrongestSiege(_ card: Card) async {
        await processDestroyStrongest(rowType: .siege)
    }

    func applyPickFrostAndPlay(_ card: Card) async {
        await processPickOneWeather(.bitingFrost)
    }

    func applyDestroyStrongestClose(_ card: Card) async {
        await processDestroyStrongest(rowType: .close)
    }

    func applyDoubleRangedPower(_ card: Card) async {
        await processDoublePower(rowType: .ranged)
    }
}

// MARK: Leader abilities helpers

private extension CardActions {
    @MainActor
    func processDestroyStrongest(rowType: Card.Row) async {
        guard let opponent = game.opponent else {
            return
        }

        let row = opponent.getRow(rowType)

        let totalPower = row.totalPower

        if totalPower < 10 {
            return
        }
        let max = row.cards
            .filter { $0.type != .hero }
            .compactMap { $0.availablePower }
            .max()

        guard let max else {
            return
        }

        let scorched = row.cards.filter { $0.availablePower == max }

        await withTaskGroup(of: Void.self) { group in
            for card in scorched {
                group.addTask {
                    await opponent.animateInContainer(card: card, as: .scorch, .row(rowType))
                }
            }
        }

        for card in scorched {
            withAnimation(.smooth(duration: 0.3)) {
                opponent.swapContainers(card, from: .row(rowType), to: .discard)
            }
        }
    }

    func processDoublePower(rowType: Card.Row) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }

        guard currentPlayer.getRow(rowType).horn == nil else {
            print("Horn is already exist")
            return
        }

        var horn = Card.all2[27]

        horn.id *= 123
        horn.isCreatedByLeader = true
        /// Буде помилка, що не видалено картку з контейнера, бо ми її щойно створили і її немає в ніякому контейнері.
        await currentPlayer.playHorn(horn, rowType: rowType)

        /// Затримка після анімації переміщення картки
        try? await Task.sleep(for: .seconds(0.3))
    }

    func processPickOneWeather(_ weatherType: Card.Weather) async {
        guard let currentPlayer = game.currentPlayer else {
            return
        }

        guard let weather = currentPlayer.deck.cards.first(where: { $0.weather == weatherType }) else {
            return
        }

        await playWeather(weather, from: .deck)
    }
}
