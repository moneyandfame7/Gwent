//
//  GameViewModel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import Observation
import SwiftUI

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

private protocol GameHelpers {
    func declareResult() async -> Void
    func compareScores() -> RoundVerdict
    func flipCoin() -> Turn
    func opponent(for player: Player) -> Player
    func getPlayer(isBot: Bool) -> Player
    func reset() -> Void
    func processWeathers() -> Void
}

private protocol CardActions {
    func playCard(_ card: Card, row: Card.Row?) async -> Void
    func playCardHorn(_ card: Card, row: Card.Row) async -> Void
    func playCardSpy(_ card: Card, row: Card.Row?) async -> Void

    func applyCardAbility(_ card: Card, row: Card.Row?) async -> Void

    /// Weathers
    func playCardWeather(_ card: Card) async -> Void
    func moveToWeathers(_ card: Card, handIndex: [Card].Index) -> Void
    func moveWeatherToDiscard(at index: [Card].Index) -> Void
}

private protocol CardAbilityActions {
    func applyTightBond(_ card: Card, rowType: Card.Row) -> Void
    func applyMuster() async -> Void
    func applyMedic() async -> Void
    func applyMoraleBoost(_ card: Card, rowType: Card.Row) -> Void

    func applyCommanderHorn() async -> Void
    func applyScorch() async -> Void
}

private protocol BotStrategyProtocol {
    func startBotTurn() async -> Void
}

@Observable
class GameViewModel {
//    let botStrategy: BotStrategyService
    let botStrategy: BotStrategy
    let settings = SettingsViewModel()
    var ui = UIViewModel()

    let player: Player
    let bot = Player()

    private(set) var firstPlayer: Player?
    private(set) var currentPlayer: Player? {
        didSet {
            if let currentPlayer {
                ui.disable(currentPlayer.isBot)
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

    var opponent: Player? {
        guard let currentPlayer else {
            return nil
        }
        return currentPlayer.isBot ? player : bot
    }

    private(set) var weathers: [Card] = []
    private(set) var isGameOver = false

    /// Round details
    private(set) var roundCount = 0
    private(set) var roundHistory: [Round] = []

    init(deck: Deck) {
        player = Player(deck: deck)
        print("GameViewModel <-- ✅Init --> Leader: \(deck.leader.name)")
        botStrategy = BotStrategy()
        botStrategy.connectGame(game: self)
    }

    deinit {
        print("GameViewModel <-- ⛔️Deinit -->")
    }
}

extension GameViewModel {
    static let preview = GameViewModel(deck: Deck.sample2())
}

// MARK: - Game Flow Protocol Implementation -

extension GameViewModel: GameFlow {
    func startGame() async {
        let coin = flipCoin()

        await ui.showNotification(coin == .bot ? .coinOp : .coinMe)

        firstPlayer = coin == .bot ? bot : player
        currentPlayer = firstPlayer

        print(" First player: \(firstPlayer!.isBot ? "Bot" : "Player")")
        try? await Task.sleep(for: .seconds(0.5)) // ?????

        await startRound()
    }

    func endGame() async {
        print(" <<< Game ended >>>")
        withAnimation(.smooth(duration: 0.3)) {
            isGameOver = true
        }
    }

    func restartGame() {
        print(" <<< Game restarted >>>")

        withAnimation {
            isGameOver = false
        }
    }

    fileprivate func startRound() async {
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

    fileprivate func endRound() async {
        print(" <<< Round ended >>> ")
        await declareResult()

        // MARK: обовʼязково погоду прибирати лише після declareResult, бо інакше результат підрахунку може бути іншим

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

    fileprivate func startTurn() async {
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

    fileprivate func endTurn() async {
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

// MARK: - Game Helpers Protocol Implementation -

extension GameViewModel: GameHelpers {
    fileprivate func declareResult() async {
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

    fileprivate func compareScores() -> RoundVerdict {
        if player.totalScore > bot.totalScore {
            return .win
        }
        if player.totalScore < bot.totalScore {
            return .lose
        }
        return .draw
    }

    fileprivate func flipCoin() -> Turn {
        Turn.allCases.randomElement()!
    }

    fileprivate func opponent(for player: Player) -> Player {
        return player.isBot ? self.player : bot
    }

    func getPlayer(isBot: Bool) -> Player {
        return isBot ? bot : player
    }

    func reset() {}

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

// MARK: - Game Card Actions Protocol Implementation -

extension GameViewModel: CardActions {
    func playCard(_ card: Card, row: Card.Row? = nil) async {
        guard let currentPlayer else {
            return
        }

        ui.selectedCard = nil

        if card.weather != nil {
            await playCardWeather(card)
        } else if card.ability == .commanderHorn && card.type == .special, let row {
            Task(priority: .background) { // TODO: remove to CardView
                SoundManager.shared.playSound2(sound: .horn)
            }

            currentPlayer.applyHorn(card, row: row)

        } else if card.ability == .spy {
            await playCardSpy(card, row: row)
        } else {
            currentPlayer.moveCard(card, row: row)
            await applyCardAbility(card, row: row)
        }

        try? await Task.sleep(for: .seconds(1))

        await endTurn()
    }

    fileprivate func playCardHorn(_ card: Card, row: Card.Row) async {}

    fileprivate func playCardSpy(_ card: Card, row: Card.Row?) async {
        guard let destination = row ?? card.combatRow else {
            return
        }

        guard let currentPlayer, let opponent else {
            return
        }

        guard let handIndex = currentPlayer.hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        guard let row = opponent.getRow(destination) else {
            return
        }

        withAnimation(.smooth(duration: 0.3)) {
            currentPlayer.removeFromHand(at: handIndex)
            // тут є трабли з анімацією, бо в рядках опонента інший неймспейс стоїть. я хз щшо робити, поки що забʼю
            // болт
            row.addCard(card)
        }

        try? await Task.sleep(for: .seconds(0.5))

        for _ in 0 ..< 2 {
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation {
                currentPlayer.drawCard()
            }
        }
    }

    fileprivate func applyCardAbility(_ card: Card, row: Card.Row?) async {
        guard let destination = row ?? card.combatRow else {
            return
        }
        guard let ability = card.ability else {
            return
        }
        print("APLY Card Ability \(card.name), [\(ability)]")

        if ability == .tightBond {
            applyTightBond(card, rowType: destination)
        } else if ability == .medic {
            await applyMedic()
            //
        } else if ability == .moraleBoost {
            applyMoraleBoost(card, rowType: destination)
            //
        } else if ability == .scorch {
            //
        } else if ability == .muster {
            //
        }
    }

    fileprivate func playCardWeather(_ card: Card) async {
        guard let currentPlayer else {
            return
        }

        guard let handIndex = currentPlayer.hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        if card.weather == .clearWeather {
            moveToWeathers(card, handIndex: handIndex)

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

        moveToWeathers(card, handIndex: handIndex)
    }

    fileprivate func moveToWeathers(_ card: Card, handIndex: Array<Card>.Index) {
        guard let currentPlayer else {
            return
        }
        guard let weather = card.weather else {
            return
        }

        let soundName = Card.getSoundAsset(weather: weather)

        Task(priority: .background) {
            SoundManager.shared.playSound(sound: soundName)
        }

        let copy = card
        copy.holderIsBot = currentPlayer.isBot
        print("Move to WEATHER, isBOT: \(copy.holderIsBot)")
        withAnimation {
            player.removeFromHand(at: handIndex)
            weathers.append(copy)
        }
    }

    fileprivate func moveWeatherToDiscard(at index: Array<Card>.Index) {
        let removed = weathers.remove(at: index)
        print("REMOVE CARD ALLLO BLYAt', \(removed.name), \(removed.holderIsBot)")
        let holder = getPlayer(isBot: removed.holderIsBot!)
        holder.moveToDiscard(removed)
//            holder.moveOneToDiscard(removed)
    }
}

// MARK: - Game Card Ability Actions Protocol Implementation -

extension GameViewModel: CardAbilityActions {
    fileprivate func applyTightBond(_ card: Card, rowType: Card.Row) {
        guard let currentPlayer else {
            return
        }
        currentPlayer.applyTightBond(card, rowType: rowType)
    }

    func applyMuster() async {
        // ось це магія єбана ваще
    }

    func applyMedic() async {
        guard let currentPlayer else {
            return
        }

        if currentPlayer.isBot {
            print("RANDOM_DISCARD_CARD")
        }
        //  Якщо бот - рандомна картка з discard, інакше карусель і там обирати.
        // Перемістити в кінець. ( в верх колоди з відбоєм )
        // Анімувати цю РАНДОМНУ ( не та, в якій абілка ) картку - чекаємо кінця анімації.
        // Зіграти негайно.
    }

    func applyMoraleBoost(_ card: Card, rowType: Card.Row) {
        guard let currentPlayer else {
            return
        }

        currentPlayer.applyMoraleBoost(card, rowType: rowType)

        // анімація автоматично
        // додаємо силу карткам в рядку окрім себе
    }

    func applyCommanderHorn() async {
        // анімація автоматично
        // подвоюємо силу карткам в рядку окрім себе
    }

    func applyScorch() async {
        // шукаємо рядок у противника, де totalPower >= 10
        // з такого рядка знаходимо картки з найвищою силою
        // анімуємо картки - чекаємо кінця анімації
        // перемістити в відбій
    }
}

// MARK: - Game Bot Strategy Protocol Implementation -

extension GameViewModel: BotStrategyProtocol {
    fileprivate func startBotTurn() async {
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
