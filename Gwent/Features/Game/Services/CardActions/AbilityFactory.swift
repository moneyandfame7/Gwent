//
//  AbilityFactory.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.01.2024.
//

import Foundation

/// - CardFactory:
///     - LeaderFactory
///     - AbilityFactory
///     - WeatherFactory
///
///
func play() {
//    let card = 
}

class AbilityBase {
    /// Bi-directional usage.
    fileprivate unowned let game: GameViewModel

    fileprivate let card: Card

    init(game: GameViewModel, card: Card) {
        self.game = game
        self.card = card
    }

    func canUse() -> Bool {
        return false
    }

    func apply(completion: @escaping () -> Void) async -> Void {}
}

final class AbilityFactory {
    /// Bi-directional usage.
    private unowned let game: GameViewModel

    init(game: GameViewModel) {
        self.game = game
    }

    func create(card: Card, rowType: Card.Row) -> AbilityBase? {
        if card.ability == .commanderHorn && card.type == .special {
            return CommanderHornAbility(game: game, card: card, rowType: rowType)
        }

        return nil
    }
}

final class CommanderHornAbility: AbilityBase {
    private let rowType: Card.Row

    init(game: GameViewModel, card: Card, rowType: Card.Row) {
        self.rowType = rowType
        super.init(game: game, card: card)
    }

    override func canUse() -> Bool {
        return true
    }

    override func apply(completion: @escaping () -> Void) async {}
}

final class ScorchAbility: AbilityBase {
    override func canUse() -> Bool {
        true
    }

    override func apply(completion: @escaping () -> Void) async {}
}

final class TightBondAbility: AbilityBase {}

final class MedicAbility: AbilityBase {
    
    
}
