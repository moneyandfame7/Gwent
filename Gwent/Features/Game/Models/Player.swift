//
//  Player.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 28.12.2023.
//

import Observation
import SwiftUI

enum Tag {
    case bot, me
}

@Observable
class Player {
    var rows: [Row]
    let isBot: Bool
    var leader: Card

    private(set) var deck: Deck
    /* private(set) */ var hand: [Card] = []
    /* private(set) */ var discard: [Card] = []
    private(set) var health = 2
    private(set) var isPassed = false
    var totalScore: Int {
        rows.reduce(0) { partialResult, combatRow in
            partialResult + combatRow.totalPower
        }
    }

    /// Означає, що лідер вже використаний / заблоковано іншим лідером ( .cancelLeaderAbility ).
    var isLeaderAvailable = false

    var canPlay: Bool {
        hand.count > 0
    }

    var tag: Tag {
        isBot ? .bot : .me
    }

    /// Initializer for the player with provided deck.
    init(deck: Deck) {
        self.deck = deck
        leader = deck.leader
        isBot = false
        rows = Row.generate(forBot: false)
//        discard = Card.inHand
    }

    /// Initializer for the bot.
    init() {
        deck = Deck.sample2
        leader = Deck.sample2.leader
        isBot = true
        rows = Row.generate(forBot: true)
    }

    func reset() {
        hand = []
        while !discard.isEmpty {
            let removed = discard.removeFirst()

            deck.cards.append(removed)
        }
    }

    func drawCard(randomHandPosition: Bool = false, randomDeckPosition: Bool = false) {
        let card = randomDeckPosition ? deck.cards.randomElement() : deck.cards.last

        guard let card, let index = deck.cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }

//        print("Pick from deck")
        deck.cards.remove(at: index)
        if randomHandPosition {
            let position = hand.randomIndex()
            hand.insert(card, at: position)
        } else {
            hand.append(card)
        }
    }

    /// Removes card from "container" and adds to row(rowType).

    func moveCard(_ card: Card, from source: CardContainer = .hand, to rowType: Card.Row) {
        withAnimation(.card) {
            removeFromContainer(card: card, source)
            addToContainer(card: card, .row(rowType))
        }

        if card.type == .hero {
            SoundManager.shared.playSound(sound: .hero)
        } else {
            switch card.combatRow {
            case .agile:
                let sound: SoundManager.SoundName = rowType == .close ? .close : .ranged
                SoundManager.shared.playSound(sound: sound)
            case .close:
                SoundManager.shared.playSound(sound: .close)
            case .ranged:
                SoundManager.shared.playSound(sound: .ranged)
            case .siege:
                SoundManager.shared.playSound(sound: .siege)
            default:
                return
            }
        }
    }

    func clearWeathers() {
        for i in rows.indices {
            rows[i].hasWeather = false
        }
    }
}

extension Player {
    static let preview = Player(deck: .sample1)
}

// MARK: Abilities

extension Player {
    /// Це special card.
    @MainActor
    func playHorn(_ card: Card, rowType: Card.Row, from container: CardContainer = .hand) async {
        guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }

        SoundManager.shared.playSound(sound: .horn)
        withAnimation(.card) {
            if !card.isCreatedByLeader {
                removeFromContainer(card: card, container)
            }

            rows[rowIndex].addHorn(card)
        }

        rows[rowIndex].showHornOverlay = true

        try? await Task.sleep(for: .seconds(2.5))

        rows[rowIndex].showHornOverlay = false
    }

    /// Це Dandelion
    @MainActor
    func applyHorn(_ card: Card, rowType: Card.Row, from container: CardContainer = .hand) async {
        guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }
//        rows[rowIndex].calculateCardsPower()

        SoundManager.shared.playSound(sound: .horn)

        rows[rowIndex].hornEffects += 1

        rows[rowIndex].showHornOverlay = true

        try? await Task.sleep(for: .seconds(2.5))

        rows[rowIndex].showHornOverlay = false
    }

    func applyWeather(_ type: Card.Weather) {
        var rowType: Card.Row

        switch type {
        case .bitingFrost:
            rowType = .close
        case .impenetrableFog:
            rowType = .ranged
        case .torrentialRain:
            rowType = .siege
        default:
            return
        }

        guard let index = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }
        rows[index].hasWeather = true
    }

    func applyTightBond(_ card: Card, rowType: Card.Row) {
        guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }

        let bonds = rows[rowIndex].cards.filter { $0.name == card.name }

        guard bonds.count > 1 else {
            return
        }

        SoundManager.shared.playSound(sound: .tightBond)

        for card in bonds {
            guard let cardIndex = rows[rowIndex].cards.firstIndex(where: { $0.id == card.id }) else {
                return
            }

            rows[rowIndex].cards[cardIndex].editedPower = rows[rowIndex].calculateCardPower(card)
            Task { @MainActor in
                rows[rowIndex].cards[cardIndex].animateAs = .tightBond(multiplier: bonds.count)

                try? await Task.sleep(for: .seconds(2))

                rows[rowIndex].cards[cardIndex].animateAs = nil
            }
        }
    }

    func applyMoraleBoost(_ card: Card, rowType: Card.Row) {
        guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }

//        rows[rowIndex].moraleBoost += 1
    }

    @MainActor
    func applyMuster(_ card: Card, rowType: Card.Row) async {
        guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
            return
        }

        guard let cardIndex = rows[rowIndex].cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        let separatorIndex = card.name.firstIndex(of: Character(":"))

        let cardName = if let separatorIndex {
            String(card.name.prefix(upTo: separatorIndex))
        } else {
            card.name
        }

        let predicate: (Card) -> Bool = { $0.name.starts(with: cardName) }

        let handUnits = hand.filter(predicate)
        let deckUnits = deck.cards.filter(predicate)

        if handUnits.isEmpty && deckUnits.isEmpty {
            return
        }

        rows[rowIndex].cards[cardIndex].shouldAnimate = true

        try? await Task.sleep(for: .seconds(2))

        rows[rowIndex].cards[cardIndex].shouldAnimate = false

//        try? await Task.sleep(for: .seconds(1))

        for card in handUnits {
            if let rowType = card.availableRow {
                moveCard(card, from: .hand, to: rowType)
            }
            /// animate as musterInserted??
        }
        for card in deckUnits {
            if let rowType = card.availableRow {
                moveCard(card, from: .deck, to: rowType)
            }
            /// animate as musterInserted???
        }

//        try? await Task.sleep(for: .seconds(0.5))
    }
}

// MARK: Row helpers

extension Player {
    func getRow(_ rowType: Card.Row) -> Row {
        return rows.first { $0.type == rowType }!
    }

    func clearRows() {
//        var rowExceptionIndex: Int?
        var cardException: Card?

        // MARK: #FactionAbility - Monsters: Handling

        if deck.faction == .monsters {
            let rowsWithUnits = rows.filter { $0.cards.filter { $0.type == .unit }.count > 0 }

            if rowsWithUnits.count > 0 {
                let randomRow = rowsWithUnits.randomElement()!

                let rowIndex = rows.firstIndex(where: { $0.type == randomRow.type })!

                cardException = rows[rowIndex].cards.randomElement()
            }
        }

        withAnimation(.card) {
            for i in rows.indices {
                let cards = rows[i].cards

                if let horn = rows[i].horn {
                    rows[i].horn = nil
                    if !horn.isCreatedByLeader {
                        addToContainer(card: horn, .discard)
                    }
                }

                rows[i].cards.removeAll(where: { $0.id != cardException?.id })
                discard.append(contentsOf: cards.filter { $0.id != cardException?.id })

                rows[i].moraleBoost = 0
                rows[i].hornEffects = 0
            }
        }
    }
}

// MARK: Container helpers

extension Player {
    func swapContainers(_ card: Card, from source: CardContainer, to destination: CardContainer) {
        removeFromContainer(card: card, source)
        addToContainer(card: card, destination)
    }

    /// Adds card to specific row and calculate edited power of card.
    func insertToContainer(_ card: Card, _ container: CardContainer, at: Int) {
        let copy = card.withResetedPower()

        switch container {
        case .hand:
            hand.insert(copy, at: at)
        case .deck:
            deck.cards.insert(copy, at: at)
        case .discard:
            discard.insert(copy, at: at)
        case let .row(rowType):
            guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
                return
            }
            rows[rowIndex].addCard(copy, at: at)

        default:
            print("Unsupported container in Player <insertToContainer>")
            return
        }
    }

    func addToContainer(card: Card, _ container: CardContainer) {
        var copy = card
        copy.editedPower = nil

        switch container {
        case .hand:
            hand.append(copy)

        case .deck:
            deck.cards.append(copy)

        case .discard:
            discard.append(copy)

        case let .row(rowType):
            guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
                print("Row index hui pizda")
                fatalError()
            }

            rows[rowIndex].addCard(copy)

        default:
            fatalError("Unsupported container in Player")
        }
    }

    @MainActor
    func animateInContainer(card: Card, as animation: Card.Animation? = nil, _ container: CardContainer) async {
        switch container {
        case let .row(rowType):
            guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
                return
            }
            guard let cardIndex = rows[rowIndex].cards.firstIndex(where: { $0.id == card.id }) else {
                return
            }
            rows[rowIndex].cards[cardIndex].shouldAnimate = true
            rows[rowIndex].cards[cardIndex].animateAs = animation

            try? await Task.sleep(for: .seconds(2))

            rows[rowIndex].cards[cardIndex].shouldAnimate = false
            rows[rowIndex].cards[cardIndex].animateAs = nil
        default:
            print("‼️ Not realized")
        }
    }

    func removeFromContainer(at: Int, _ container: CardContainer) {
        switch container {
        case .hand:
            hand.remove(at: at)
        case .deck:
            deck.cards.remove(at: at)
        case .discard:
            discard.remove(at: at)
        case let .row(rowType):
            guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
                print("‼️ Not found row \(rowType)")

                return
            }

            rows[rowIndex].removeCard(at: at)
        default:
            print("‼️ Not realized")
        }
    }

    func removeFromContainer(card: Card, _ container: CardContainer) {
        print("RemoveFromContainer")
        switch container {
        case .hand:
            guard let index = hand.firstIndex(where: { $0.id == card.id }) else {
                print("‼️ Not found card in hand")

                return
            }
            hand.remove(at: index)

        case .deck:
            guard let index = deck.cards.firstIndex(where: { $0.id == card.id }) else {
                print("‼️ Not found card in deck")

                return
            }
            deck.cards.remove(at: index)

        case .discard:
            guard let index = discard.firstIndex(where: { $0.id == card.id }) else {
                print("‼️ Not found card in discard")

                return
            }
            discard.remove(at: index)

        case let .row(rowType):
            guard let rowIndex = rows.firstIndex(where: { $0.type == rowType }) else {
                print("‼️ Not found row \(rowType)")

                return
            }

            rows[rowIndex].removeCard(card)

        default:
            fatalError("Unsupported container in Player")
        }
    }
}

// MARK: Game helpers

extension Player {
    func passRound() {
        isPassed = true
    }

    func endRound(isWin: Bool) {
        /// Move all cards to discard pile.
        clearRows()

        if !isWin {
            if health < 1 { return }

            health -= 1
        }
        isPassed = false
    }
}
