//
//  GameViewModel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import Observation
import SwiftUI


@Observable
final class GameViewModel {
    static let preview = GameViewModel(deck: .sample1)
    var ui = UIViewModel()

    let settings = SettingsViewModel()

    var player: Player
    var bot: Player

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
        let verdict = compareScores()

        switch verdict {
        case .win:
            return player
        case .lose:
            return bot
        case .draw:
            return nil
        }
    }

    var isGameOver = false
    var opponent: Player? {
        guard let currentPlayer else {
            return nil
        }
        return currentPlayer.isBot ? player : bot
    }

    var weathers: [Card] = [] {
        didSet {
            processWeathers()
        }
    }

    /// Round details
    var roundCount = 0
    var roundHistory: [Any] = []

    init(deck: Deck) {
        player = Player(deck: deck)
        bot = Player()
    }
}

// MARK: - Game flow -

private protocol GameFlow {
    /// Main game flow
    func startGame() async -> Void
    func endGame() async -> Void
    func restartGame() -> Void

    /// Round flow
    func startRound() async -> Void
    func endRound() async -> Void
    func passRound() async -> Void

    /// Turn flow
    func startTurn() async -> Void
    func endTurn() async -> Void
}

extension GameViewModel: GameFlow {
    func startGame() async {
        let coin = flipCoin()

        await ui.showNotification(coin == .bot ? .coinOp : .coinMe)

        Task(priority: .background) {
            SoundManager.shared.playSound2(sound: .deck)
        }
        for _ in 0 ..< 10 {
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.smooth(duration: 0.3)) {
                player.drawCard()
                bot.drawCard()
            }
        }

        firstPlayer = coin == .bot ? bot : player
        currentPlayer = firstPlayer

        print(" First player: \(firstPlayer!.isBot ? "Bot" : "Player")")
        try? await Task.sleep(for: .seconds(0.5)) // ?????

        await startRound()
    }

    func endGame() async {
        withAnimation {
            isGameOver = true
        }
        print(" <<< Game ended >>>")
    }

    func restartGame() {
        withAnimation {
            isGameOver = false
        }
        print(" <<< Game restarted >>>")
    }

    func startRound() async {
        print(" <<< Round started >>>")

        roundCount += 1

        currentPlayer = (roundCount % 2 == 0) ? firstPlayer : opponent

        // TODO: мб спробувати розібратись, щоб зайві рази не мінявся currentPlayer
        // при старті грі воно два рази міняється...
        // або просто зробити флаг по типу "shouldHighlightCurrentPlayer" ??? і викликати його можна після повідомлення
        // чи я хз де

        if !player.canPlay {
            player.passRound()
        }
        if !bot.canPlay {
            bot.passRound()
        }

        if player.isPassed && bot.isPassed {
            return await endRound()
        }
        if let currentPlayer, currentPlayer.isPassed {
            /// Трохи вище, ми робимо player.isPassed, bot.isPassed, якщо вже немає карт для ходу.
            /// Якщо гравець, який зараз буде ходити, немає більше карток, тобто пасанув, то передаємо хід іншому
            /// гравцю.
            self.currentPlayer = opponent
        }

        await ui.showNotification(.roundStarted)
        await startTurn()
    }

    func endRound() async {
        print(" <<< Round ended >>> ")
        await declareResult()

        // MARK: обовʼязково погоду прибирати лише після declareResult, тому що тоді результат може бути іншим

        weathers.removeAll()

        if player.health == 0 || bot.health == 0 {
            await endGame()
        } else {
            await startRound()
        }
    }

    func passRound() async {
        print(" <<< Round passed >>>")
        currentPlayer?.passRound()

        await endTurn()
    }

    func startTurn() async {
        print(" <<< Turn started >>>")
        guard let opponent else {
            return
        }
        if !opponent.isPassed {
            currentPlayer = opponent

            try? await Task.sleep(for: .seconds(0.5)) // ?????

            await ui.showNotification(currentPlayer!.isBot ? .turnOp : .turnMe)
        }

        if let currentPlayer, currentPlayer.isBot {
            await startBotTurn()
        }
    }

//    @MainActor
    func endTurn() async {
        print(" <<< Turn ended >>>")

        guard let currentPlayer else {
            return
        }
        if !currentPlayer.isPassed && !currentPlayer.canPlay {
            currentPlayer.passRound()
        }

        if currentPlayer.isPassed {
            await ui.showNotification(currentPlayer.isBot ? .roundPassedOp : .roundPassedMe)
        }

        if player.isPassed && bot.isPassed {
            await endRound()
        } else {
            await startTurn()
        }
    }
}

// MARK: - Helpers -

enum Turn: String, CaseIterable {
    case player, bot
}

enum RoundVerdict: String, CaseIterable {
    case win, draw, lose
}

private protocol GwentHelpers {
    // Round results
    func declareResult() async -> Void
    func compareScores() -> RoundVerdict
    func flipCoin() -> Turn
    func opponent(for player: Player) -> Player
    func getPlayer(isBot: Bool) -> Player

    func getCardContainer(_ container: CardContainer, player: Player) -> [Card]
}

extension GameViewModel: GwentHelpers {
    func declareResult() async {
        let verdict = compareScores()

        switch verdict {
        case .win:
            await ui.showNotification(.roundWin)
        case .lose:
            await ui.showNotification(.roundLose)
        case .draw:
            await ui.showNotification(.roundDraw)
        }

        player.endRound(isWin: verdict == .win)
        bot.endRound(isWin: verdict == .lose)
    }

    func compareScores() -> RoundVerdict {
        if player.totalScore > bot.totalScore {
            return .win
        }
        if player.totalScore < bot.totalScore {
            return .lose
        }
        return .draw
    }

    func flipCoin() -> Turn {
        Turn.allCases.randomElement()!
    }

    func opponent(for player: Player) -> Player {
        return player.isBot ? self.player : bot
    }

    func getPlayer(isBot: Bool) -> Player {
        return isBot ? bot : player
    }

    func getCardContainer(_ container: CardContainer, player: Player) -> [Card] {
        switch container {
        case let .row(row):
            return player.getRow(row).cards
        case .discard:
            return player.discard
        case .hand:
            return player.hand
        case .deck:
            return player.deck.cards
        case .weathers:
            return weathers
        }
    }
}

// MARK: - Bot Turns, random card generation and more -

/// можливо треба зробити окрему структуру щось типу AIController або щось таке

private protocol BotStrategy {
    func startBotTurn() async -> Void
}

extension GameViewModel: BotStrategy {
    func startBotTurn() async {
        guard let opponent else {
            return
        }

        /// Якщо бот в переможній ситуації і вже пасанули - теж пасує.
        if let leadingPlayer, opponent.isPassed && leadingPlayer.isBot {
            await passRound()
            return
        }
        /// На кількість карток перевіряємо в turnEnd і roundStart,  тому force unwrap ????
        let card = bot.hand.randomElement()!

        if card.ability == .agile {
            let randomRow = Int.random(in: 0 ... 1)
            await playCard(card, row: randomRow == 0 ? .close : .ranged)
        } else {
            await playCard(card)
        }
    }
}

// MARK: Different card actions

private protocol CardActions {
    func playCard(_ card: Card, row: Card.Row?, from container: CardContainer) async -> Void
    func playCardHorn(_ card: Card, row: Card.Row, from container: CardContainer) async -> Void
    func playCardSpy(_ card: Card, row: Card.Row?, from container: CardContainer) async -> Void

    func applyCardAbility(_ card: Card, row: Card.Row?, from container: CardContainer) async -> Void

    /// Weathers
    func playCardWeather(_ card: Card, player: Player, from container: CardContainer) async -> Void
    func moveToWeathers(_ card: Card, player: Player, from container: CardContainer) -> Void
    func moveWeatherToDiscard(at index: [Card].Index) -> Void
    func processWeathers() -> Void
}

private protocol CardAbilityActions {
    func applyTightBond(_ card: Card, rowType: Card.Row) -> Void
    func applyMuster() async -> Void
    func applyMedic(_ card: Card, rowType: Card.Row) async -> Void
    func applyMoraleBoost(_ card: Card, rowType: Card.Row) -> Void

    func applyCommanderHorn(_ card: Card, rowType: Card.Row) -> Void
    func applyScorch() async -> Void
}

extension GameViewModel: CardAbilityActions {
    func applyTightBond(_ card: Card, rowType: Card.Row) {
        guard let currentPlayer else {
            return
        }
        currentPlayer.applyTightBond(card, rowType: rowType)
    }

    func applyMuster() async {}

//    @MainActor
    func applyMedic(_ card: Card, rowType: Card.Row) async {
        guard let currentPlayer else {
            return
        }
        let units = currentPlayer.discard.filter { $0.type != .special && $0.type != .hero }

        if units.count <= 0 {
            return
        }

        if currentPlayer.isBot {
            Task {
                let randomCard = units.randomElement()!
                await processMedic(randomCard)
            }

        } else {
            ui.showCarousel(Carousel(
                cards: units,
                count: 2,
                title: "",
                action: { [self] card in
                    Task {
                        ui.carousel = nil
                        await processMedic(card)
                    }
                }
            ))
        }

        @Sendable
        func processMedic(_ card: Card) async {
            currentPlayer.removeFromContainer(card: card, .discard)
            currentPlayer.addToContainer(card: card, .discard)

            let topDiscardIndex = currentPlayer.discard.endIndex - 1

            currentPlayer.discard[topDiscardIndex].animateAs = .medic

            try? await Task.sleep(for: .seconds(2))

            currentPlayer.discard[topDiscardIndex].animateAs = nil

            try? await Task.sleep(for: .seconds(0.2))

            await playCard(card, from: .discard)
        }
    }

    func applyMoraleBoost(_ card: Card, rowType: Card.Row) {
        guard let currentPlayer else {
            return
        }
        currentPlayer.applyMoraleBoost(card, rowType: rowType)
    }

    func applyCommanderHorn(_ card: Card, rowType: Card.Row) {
        guard let currentPlayer else {
            return
        }
        currentPlayer.applyMoraleBoost(card, rowType: rowType)
    }

    func applyScorch() async {
        // шукаємо рядок у противника, де totalPower >= 10
        // з такого рядка знаходимо картки з найвищою силою
        // анімуємо картки - чекаємо кінця анімації
        // перемістити в відбій
    }
}

extension GameViewModel: CardActions {
    @MainActor
    func playCard(_ card: Card, row: Card.Row? = nil, from container: CardContainer = .hand) async {
        guard let currentPlayer else {
            return
        }

        ui.selectedCard = nil
        print("Card to play: \(card.name)")
        if card.weather != nil {
            await playCardWeather(card, player: currentPlayer)
        } else if card.ability == .commanderHorn && card.type == .special, let row {
            Task(priority: .background) { // TODO: remove to CardView
                SoundManager.shared.playSound2(sound: .horn)
            }

            currentPlayer.applyHorn(card, row: row)

        } else if card.ability == .spy {
            await playCardSpy(card, row: row, from: container)
        } else {
            currentPlayer.moveCard(card, rowType: row, from: container)

            if card.ability != nil {
                await applyCardAbility(card, row: row, from: container)
                return
            }
        }

        try? await Task.sleep(for: .seconds(1))

        await endTurn()
    }

    fileprivate func playCardHorn(_ card: Card, row: Card.Row, from container: CardContainer = .hand) async {}

    fileprivate func playCardSpy(_ card: Card, row: Card.Row?, from container: CardContainer = .hand) async {
        let destination = row ?? card.combatRow

        guard let currentPlayer, let opponent else {
            return
        }
        guard let rowIndex = opponent.rows.firstIndex(where: { $0.type == destination }) else {
            return
        }

        withAnimation(.smooth(duration: 0.3)) {
            currentPlayer.removeFromContainer(card: card, container)
//            currentPlayer.removeFromHand(at: handIndex)
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

    fileprivate func applyCardAbility(_ card: Card, row: Card.Row?, from container: CardContainer = .hand) async {
        guard let destination = row ?? card.combatRow else {
            return
        }
//        guard let ability = card.ability else {
//            await endTurn()
//            return
//        }

        if card.ability == .tightBond {
            applyTightBond(card, rowType: destination)
        } else if card.ability == .moraleBoost {
            applyMoraleBoost(card, rowType: destination)
        } else if card.ability == .medic {
            try? await Task.sleep(for: .seconds(2))
            await applyMedic(card, rowType: destination)

            return
        }

        await endTurn()
    }

    fileprivate func playCardWeather(_ card: Card, player: Player, from container: CardContainer = .hand) async {
        guard let handIndex = player.hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        if card.weather == .clearWeather {
            moveToWeathers(card, player: player, from: container)

            let filtered = weathers.filter { $0.weather != .clearWeather }

            /// Remove all other weathers
            withAnimation {
                for card in filtered {
                    guard let index = weathers.firstIndex(where: { $0.id == card.id }) else {
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

            return
        }

        // MARK: - Common weather ( except Clear Weather )

        let sameWeatherIndex = weathers.firstIndex(where: { ($0.id == card.id) || ($0.weather == card.weather) })

        if let sameWeatherIndex {
            withAnimation(.smooth(duration: 0.3)) {
                moveWeatherToDiscard(at: sameWeatherIndex)
            }
            try? await Task.sleep(for: .seconds(0.55))
        }

        moveToWeathers(card, player: player, from: container)
    }

    fileprivate func moveToWeathers(
        _ card: Card,
        player: Player,
        from container: CardContainer = .hand
    ) {
        guard let weather = card.weather else {
            return
        }

        let soundName = Card.getSoundAsset(weather: weather)

        Task(priority: .background) {
            SoundManager.shared.playSound(sound: soundName)
        }
        var copy = card
        copy.holderIsBot = player.isBot

        withAnimation {
//            player.removeFromHand(at: handIndex)
            player.removeFromContainer(card: card, container)
            weathers.append(copy)
        }
    }

    fileprivate func moveWeatherToDiscard(at index: [Card].Index) {
        let removed = weathers.remove(at: index)

        let holder = getPlayer(isBot: removed.holderIsBot!)

        holder.moveToDiscard(removed)
    }

    fileprivate func processWeathers() {
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
