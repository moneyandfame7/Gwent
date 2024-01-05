//
//  CombatRow.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import Foundation

struct CombatRow {
    let type: Card.CombatRow
    // TODO: треба зробити це private set, додати функцію addCard, і там вже calculateCard score???
    var cards: [Card] = []

    var horn: Card? {
        didSet {
            for i in cards.indices {
                let power = cards[i].editedPower ?? cards[i].power

                if let power, cards[i].type != .hero {
                    cards[i].editedPower = horn != nil ? power * 2 : nil // * hornCount ?? чи як це
                }
            }
        }
    }

    var hasWeather = false {
        didSet {
            calculateCardsPower()
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

    private mutating func calculateCardsPower() {
        for i in cards.indices {
            if cards[i].type != .hero {
                var total: Int = cards[i].power ?? 0

                if hasWeather {
                    total = 1
                }

                let bond = cards.filter { $0.name == cards[i].name }

                if bond.count > 1 {
                    total *= bond.count
                }

                // -1 --> тому що абілка додає до всіх карток ОКРІМ себе
                total += max(0, moraleBoost + (cards[i].ability == .moraleBoost ? -1 : 0))

                cards[i].editedPower = total
            }
        }
    }
}

extension CombatRow {
    static func generate(isEmpty: Bool = false, forBot: Bool = false) -> [Self] {
        return [
            CombatRow(type: .close, cards: isEmpty ? [] : Array(Card.all2[0 ... 3])),
            CombatRow(type: .ranged, cards: isEmpty ? [] : Array(Card.all2[3 ... 6])),
            CombatRow(type: .siege, cards: isEmpty ? [] : Array(Card.all2[6 ... 7])),
        ].reversed(forBot)
    }
}
