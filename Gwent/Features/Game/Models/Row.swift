//
//  Row.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import Observation
import SwiftUI

@Observable
final class Row {
    let type: Card.Row
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
            for card in cards {
                card.editedPower = calculateCardPower(card)
            }
        }
    }

    var moraleBoost: Int = 0 {
        didSet {
            for card in cards {
                card.editedPower = calculateCardPower(card)
            }
        }
    }

    var tightBond: [String: Int] = [:]

    var totalPower: Int {
        cards.reduce(0) { partialResult, card in

            partialResult + (card.editedPower ?? card.power ?? 0)
        }
    }

    init(type: Card.Row, cards: [Card] = []) {
        self.type = type
        self.cards = cards
    }

    func addCard(_ card: Card) {
        card.editedPower = calculateCardPower(card)

        let randomPositionAtRow = cards.randomIndex()

        cards.insert(card, at: randomPositionAtRow)
    }

     func calculateCardPower(_ card: Card) -> Int {
        var total: Int = card.power ?? 0

        if hasWeather {
            total = 1
        }

        let bond = cards.filter { $0.name == card.name }

        if bond.count > 1 {
            total *= bond.count
        }

        // -1 --> тому що абілка додає до всіх карток ОКРІМ себе
        total += max(0, moraleBoost + (card.ability == .moraleBoost ? -1 : 0))

         // TODO: перерахувати всі можливі ефекти на картці, але поки що буде ось так???
         // в CardView в мене якщо editedPower <= power, то буде червона, але зроблю, щоб було тільки якщо <
//         if total == card.power && hasWeather {
//             
//         }
//         
         return total
    }
}

extension Row {
    static func generate(isBot: Bool) -> [Row] {
        return [
            Row(type: .close),
            Row(type: .ranged),
            Row(type: .siege),
        ].reversed(isBot)
    }
}
