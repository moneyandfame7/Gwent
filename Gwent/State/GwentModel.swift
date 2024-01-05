//
//  GwentModel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import Observation
import SwiftUI

// TODO: rename to GameViewModel
@Observable
final class GwentModel {
    static let preview = GwentModel(ui: UIManager.preview)
    private let ui: UIManager

    var player: PlayerClass
    var bot: PlayerClass

    /// Players, based on game progress.
    var firstPlayer: PlayerClass?
    var currentPlayer: PlayerClass? {
        didSet {
            if let currentPlayer {
                ui.isDisabled = currentPlayer.isBot
            }
        }
    }

    var leadingPlayer: PlayerClass? {
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

    var opponent: PlayerClass? {
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

    init(ui: UIManager) {
        self.ui = ui
        player = PlayerClass()
        bot = PlayerClass(isBot: true)
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

extension GwentModel: GameFlow {
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
    }

    func restartGame() {
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
            player.isPassed = true
        }
        if !bot.canPlay {
            bot.isPassed = true
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
        currentPlayer?.isPassed = true

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

    func endTurn() async {
        print(" <<< Turn ended >>>")

        guard let currentPlayer else {
            return
        }
        if !currentPlayer.isPassed && !currentPlayer.canPlay {
            currentPlayer.isPassed = true
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
    func opponent(for player: PlayerClass) -> PlayerClass
    func getPlayer(isBot: Bool) -> PlayerClass
}

extension GwentModel: GwentHelpers {
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

    func opponent(for player: PlayerClass) -> PlayerClass {
        return player.isBot ? self.player : bot
    }

    func getPlayer(isBot: Bool) -> PlayerClass {
        return isBot ? bot : player
    }
}

// MARK: - Bot Turns, random card generation and more -

/// можливо треба зробити окрему структуру щось типу AIController або щось таке

private protocol BotStrategy {
    func startBotTurn() async -> Void
}

extension GwentModel: BotStrategy {
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
    func playCard(_ card: Card, row: Card.CombatRow?) async -> Void
    func playCardHorn(_ card: Card, row: Card.CombatRow) async -> Void
    func playCardSpy(_ card: Card, row: Card.CombatRow?) async -> Void

    func applyCardAbility(_ card: Card, row: Card.CombatRow?) -> Void

    /// Weathers
    func playCardWeather(_ card: Card, player: PlayerClass) async -> Void
    func moveToWeathers(_ card: Card, player: PlayerClass, handIndex: [Card].Index) -> Void
    func moveWeatherToDiscard(at index: [Card].Index) -> Void
    func processWeathers() -> Void
}

private protocol CardAbilityActions {
    func applyTightBond(_ card: Card, row: Card.CombatRow) -> Void
    func applyMuster() async -> Void
    func applyMedic() async -> Void
    func applyMoraleBoost(_ card: Card, row: Card.CombatRow) async -> Void

    func applyCommanderHorn() async -> Void
    func applyScorch() async -> Void
}

extension GwentModel: CardAbilityActions {
    func applyTightBond(_ card: Card, row: Card.CombatRow) {
        guard let currentPlayer else {
            return
        }

        guard let rowIndex = currentPlayer.rows.firstIndex(where: { $0.type == row }) else {
            return
        }
        currentPlayer.rows[rowIndex].tightBond[card.name] = (currentPlayer.rows[rowIndex].tightBond[card.name] ?? 0) + 1

        let bonds = currentPlayer.rows[rowIndex].cards.filter { $0.name == card.name }

        guard bonds.count > 1 else {
            return
        }

        print("IT IS BOND, JAMES BOND")

        for card in bonds {
            guard let power = card.power else {
                return
            }
            guard let cardIndex = currentPlayer.rows[rowIndex].cards.firstIndex(where: { $0.id == card.id }) else {
                return
            }

//            let editedPower = currentPlayer.rows[rowIndex].cards[cardIndex].editedPower ?? 0
            currentPlayer.rows[rowIndex].cards[cardIndex]
                .editedPower = (currentPlayer.rows[rowIndex].hasWeather ? 1 : power) * bonds
                .count

            Task {
                await self.ui.animateCard(card, player: currentPlayer, source: .close)
            }
        }
    }

    func applyMuster() async {}

    func applyMedic() async {
        // Рандомна картка з discard.
        // Перемістити в кінець. ( в верх колоди з відбоєм )
        // Анімувати цю РАНДОМНУ ( не та, в якій абілка ) картку - чекаємо кінця анімації.
        // Зіграти негайно.
    }

    func applyMoraleBoost(_ card: Card, row: Card.CombatRow) async {
        guard let currentPlayer else {
            return
        }

        guard let rowIndex = currentPlayer.rows.firstIndex(where: { $0.type == row }) else {
            return
        }
        currentPlayer.rows[rowIndex].moraleBoost += 1
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

extension GwentModel: CardActions {
//    @MainActor
    func playCard(_ card: Card, row: Card.CombatRow? = nil) async {
        guard let currentPlayer else {
            return
        }

        ui.selectedCard = nil

        if card.weather != nil {
            await playCardWeather(card, player: currentPlayer)
        } else if card.ability == .commanderHorn && card.type == .special, let row {
            Task(priority: .background) { // TODO: remove to CardView
                SoundManager.shared.playSound2(sound: .horn)
            }

            currentPlayer.addHorn(card, row: row)

        } else if card.ability == .spy {
            await playCardSpy(card, row: row)
        } else {
            currentPlayer.moveCard(card, row: row)
            applyCardAbility(card, row: row)
        }

        try? await Task.sleep(for: .seconds(1))

        await endTurn()
    }

    fileprivate func playCardHorn(_ card: Card, row: Card.CombatRow) async {}

    fileprivate func playCardSpy(_ card: Card, row: Card.CombatRow?) async {
        let destination = row ?? card.combatRow

        guard let currentPlayer, let opponent else {
            return
        }
        guard let handIndex = currentPlayer.hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }
        guard let rowIndex = opponent.rows.firstIndex(where: { $0.type == destination }) else {
            return
        }

        let randomPosition = opponent.rows[rowIndex].cards.randomIndex()
        var copy = card
        if opponent.rows[rowIndex].hasWeather && copy.type != .hero {
            copy.editedPower = 1
        }
        withAnimation(.smooth(duration: 0.3)) {
            currentPlayer.hand.remove(at: handIndex)
            // тут є трабли з анімацією, бо в рядках опонента інший неймспейс стоїть. я хз щшо робити, поки що забʼю
            // болт
            opponent.rows[rowIndex].cards.insert(copy, at: randomPosition)
        }

        try? await Task.sleep(for: .seconds(0.5))

        for _ in 0 ..< 2 {
            try? await Task.sleep(for: .seconds(0.1))
            withAnimation(.smooth(duration: 0.3)) {
                currentPlayer.pickFromCards(randomHandPosition: true)
            }
        }
    }

    fileprivate func applyCardAbility(_ card: Card, row: Card.CombatRow?) {
        guard let destination = row ?? card.combatRow else {
            return
        }
        guard let ability = card.ability else {
            return
        }
        guard let currentPlayer else {
            return
        }

        guard let rowIndex = currentPlayer.rows.firstIndex(where: { $0.type == destination }) else {
            return
        }

        if ability == .tightBond {
            applyTightBond(card, row: destination)
        }
    }

    fileprivate func playCardWeather(_ card: Card, player: PlayerClass) async {
        guard let handIndex = player.hand.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        if card.weather == .clearWeather {
            moveToWeathers(card, player: player, handIndex: handIndex)

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

        moveToWeathers(card, player: player, handIndex: handIndex)
    }

    fileprivate func moveToWeathers(_ card: Card, player: PlayerClass, handIndex: [Card].Index) {
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
            player.hand.remove(at: handIndex)
            weathers.append(copy)
        }
    }

    fileprivate func moveWeatherToDiscard(at index: [Card].Index) {
        let removed = weathers.remove(at: index)

        let holder = getPlayer(isBot: removed.holderIsBot!)

        holder.moveOneToDiscard(removed)
    }

    fileprivate func processWeathers() {
        if weathers.isEmpty {
            player.removeWeathers()
            bot.removeWeathers()
        } else {
            weathers.forEach { card in
                player.addWeatherToRow(type: card.weather!)
                bot.addWeatherToRow(type: card.weather!)
            }
        }
    }
}
