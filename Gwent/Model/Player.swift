//
//  Player.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import Foundation



protocol GwentPlayer {
    var cards: [Card] { get set }
    var combatRows: [CombatRow] { get set }
    
    

    //  mutating  func addWeather(type: Card.Weather) -> Void

    // deck, discard pile, hand
    // можливо, combatRows треба винести кудись в інше місце?
    // TODO: add init with cards, leader, fraction
}


struct Player: GwentPlayer {
    var cards: [Card] = Card.inHand
    var combatRows: [CombatRow] = CombatRow.generate()
    var handSize: Int {
        cards.count
    }

    var totalScore: Int {
        combatRows.reduce(0) { partialResult, combatRow in
            partialResult + combatRow.totalPower
        }
    }

    // TODO: винести це кудись, наприклад в структуру Board ???????
    mutating func addWeather(type: Card.Weather) {
        var rowType: Card.CombatRow

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

        guard let index = self.combatRows.firstIndex(where: { $0.type == rowType }) else {
            return
        }
        self.combatRows[index].hasWeather = true
    }
}

struct Bot: GwentPlayer {
    var cards: [Card] = []

    var combatRows: [CombatRow] = CombatRow.generate(forBot: true)

    init() {
        let faction = self.pickRandomFaction()
        let countOfCards = self.generateCountOfCards(faction: faction)
        let leader = Card.random(faction: faction, isLeader: true)

        print("--- Bot generation ---")
        print("Faction: \(faction), leader: \(leader?.name ?? "<nil>")")
        print("Count of cards: ", countOfCards)

        print("--- Card generation ---")

        for i in 0 ..< countOfCards {
            guard let card = self.pickRandomCard(faction: faction) else {
                print("Card not found")
                return
            }

            self.cards.append(card)
            print("[\(i)]: Random Card, Name: ", card.name, "Copies: \(card.copies)")

            //            let card = self.cards.randomElement()!
        }

        print(Date.now.formatted())
    }

    mutating func addWeather(type: Card.Weather) {
        var rowType: Card.CombatRow

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

        guard let index = self.combatRows.firstIndex(where: { $0.type == rowType }) else {
            return
        }
        self.combatRows[index].hasWeather = true
    }

    private func pickRandomCard(faction: Card.Faction) -> Card? {
        let excludeIds = self.cards.map { $0.id }

        let card = Card.random(faction: faction, excludeIds: excludeIds)

        // MARK: потрібно юзати імʼя, бо в картки кожної унікальний айді, але повторки можуть бути

        let alreadyExist = cards.contains { $0.name == card?.name }

        if !alreadyExist {
            return card
        }

        // regenerate, because only 1 hero can be
        if card?.type == .hero {
            print("--- SHOULD REGENERATE FOR: ", card?.name)
            return pickRandomCard(faction: faction)
        }

        guard let copiesCount = card?.copies else {
            print("--- SHOULD REGENERATE FOR: ", card?.name)
            return pickRandomCard(faction: faction)
        }

        let currentCopies = self.cards.filter { $0.name == card?.name }

        /// Якщо поточна кількість копій карт меньша, ніж може бути - повертаємо її
        if currentCopies.count < copiesCount {
            return card
        }

        print("--- XZ WTO TYT _--- ", card?.name)
        return pickRandomCard(faction: faction)

//
//        if let copiesCount = card?.copies {
//            let cardCopies = self.cards.filter { $0.name == card?.name }
//            if cardCopies.count >= copiesCount {
//                // regenerate, because the limit of these cards is exceeded
//            }
//        }
    }

    private func generateCountOfCards(faction: Card.Faction) -> Int {
        /// Better tactic for monsters, when there are many cards
        let maxCount = faction == .monsters ? 40 : 30

        return Int.random(in: 25 ... maxCount)
    }

    private func pickRandomFaction() -> Card.Faction {
        return Card.Faction.allCases.randomElement { $0 != .neutral }!
    }
}
