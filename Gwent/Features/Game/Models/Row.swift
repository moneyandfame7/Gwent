//
//  Row.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import Foundation

struct Row {
    let type: Card.Row
    // TODO: треба зробити це private set, додати функцію addCard, і там вже calculateCard score???
    var cards: [Card] = []

    var horn: Card? {
        didSet {
            if horn == nil {
                hornEffects = min(0, hornEffects - 1)
            } else {
                hornEffects += 1
            }
        }
    }

    var hasWeather = false {
        didSet {
            calculateCardsPower()
        }
    }

    var hornEffects: Int = 0 {
        didSet {
            if hornEffects > 1 {
                return
            }

            for i in cards.indices {
                let power = cards[i].availablePower

                guard let power, cards[i].type != .hero else {
                    continue
                }

//                cards[i].editedPower = calculateCardPower(cards[i])
                if hornEffects - (cards[i].ability == .commanderHorn ? 1 : 0) > 0 {
                    // щоб не застосувати до картки з цією ж абілкою
                }

                cards[i].editedPower = hornEffects != 0 ? power * 2 : nil
            }
        }
    }

    var moraleBoost: Int = 0 {
        didSet {
            calculateCardsPower()
        }
    }

    // Card Name : Count of cards
    var tightBond: [String: Int] = [:] {
        didSet {
//            let count =
//            let bonds = cards.filter { $0.name  }
        }
    }

    var totalPower: Int {
        cards.reduce(0) { partialResult, card in

            partialResult + (card.editedPower ?? card.power ?? 0)
        }
    }

    mutating func addCard(_ card: Card, at: Int? = nil) {
        var copy = card
        copy.editedPower = calculateCardPower(copy)

        let randomPositionAtRow = cards.randomIndex()

        cards.insert(copy, at: at ?? randomPositionAtRow)
    }

    func calculateCardPower(_ card: Card) -> Int? {
        var total: Int = card.power ?? 0
        if card.type == .hero {
            return nil
        }

        if hasWeather {
            total = 1
        }

        let bonds = cards.filter { $0.name == card.name }

        if card.ability == .tightBond && bonds.count > 1 {
            total *= bonds.count
        }

        // -1 --> тому що абілка додає до всіх карток ОКРІМ себе
        total += max(0, moraleBoost + (card.ability == .moraleBoost ? -1 : 0))

        if hornEffects - (card.ability == .commanderHorn && card.type == .unit ? 1 : 0) > 0 {
            total *= 2
        }
        // TODO: перерахувати всі можливі ефекти на картці, але поки що буде ось так???
        // в CardView в мене якщо editedPower <= power, то буде червона, але зроблю, щоб було тільки якщо <
        //         if total == card.power && hasWeather {
        //
        //         }
        return total
    }

    private mutating func calculateCardsPower() {
        for i in cards.indices {
            cards[i].editedPower = calculateCardPower(cards[i])
        }
    }
}

extension Row {
    static func generate(isEmpty: Bool = false, forBot: Bool = false) -> [Self] {
        return [
            Row(type: .close),
            Row(type: .ranged),
            Row(type: .siege),
        ].reversed(forBot)
    }
}
