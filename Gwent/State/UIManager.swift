//
//  UIManager.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import Observation
import SwiftUI

enum CardSource {
    case hand, discard

    /// From row
    case close, ranged, siege
}

struct Namespaces {
    let playerCards: Namespace.ID = Namespace().wrappedValue
    let botCards: Namespace.ID = Namespace().wrappedValue
    let weatherCards: Namespace.ID = Namespace().wrappedValue
}

@Observable
final class UIManager {
    static let preview = UIManager()
    let namespaces = Namespaces()

    var notification: Notification?

    var selectedCard: Card?
    var selectedRow: CombatRow?

    var isDisabled = false

    func selectCard(_ card: Card) -> Void {
        if selectedCard?.id == card.id {
            selectedCard = nil
        } else {
            selectedCard = card
        }
    }

    func isCardSelected(_ card: Card) -> Bool {
        return card.id == selectedCard?.id
    }

    func showNotification(_ notification: Notification) async -> Void {
        withAnimation {
            self.notification = notification
        }

        let duration = notification == .coinMe || notification == .coinOp ? 2 : 1.5

        try? await Task.sleep(for: .seconds(duration))

        withAnimation {
            self.notification = nil
        }

        try? await Task.sleep(for: .seconds(0.8))
    }

    func namespace(for player: PlayerClass) -> Namespace.ID {
        return player.isBot ? namespaces.botCards : namespaces.playerCards
    }

    func namespace(isMe: Bool) -> Namespace.ID {
        return isMe ? namespaces.playerCards : namespaces.botCards
    }

    @MainActor
    func animateCard(_ card: Card, as animation: CardAnimation? = nil, player: PlayerClass, source: CardSource) async {
        if source == .hand {
            guard let cardIndex = player.hand.firstIndex(where: { $0.id == card.id }) else {
                return
            }

            player.hand[cardIndex].shouldAnimate = true
//            player.hand[cardIndex].animateAs = animation

            try? await Task.sleep(for: .seconds(2))

            player.hand[cardIndex].shouldAnimate = false
//            player.hand[cardIndex].animateAs = nil
        } else if source == .discard {
            guard let cardIndex = player.discard.firstIndex(where: { $0.id == card.id }) else {
                return
            }

            player.discard[cardIndex].shouldAnimate = true
            player.discard[cardIndex].animateAs = animation

            try? await Task.sleep(for: .seconds(2))

            player.discard[cardIndex].shouldAnimate = false
            player.discard[cardIndex].animateAs = nil
        } else {
            var row: Card.CombatRow
            switch source {
                case .close:
                    row = .close
                case .ranged:
                    row = .ranged
                case .siege:
                    row = .siege
                default:
                    return
            }
            guard let rowIndex = player.rows.firstIndex(where: {$0.type == row}) else {
                return
            }
            guard let cardIndex = player.rows[rowIndex].cards.firstIndex(where: {$0.id == card.id}) else {
                return
            }
            
            
            player.rows[rowIndex].cards[cardIndex].shouldAnimate = true
            player.rows[rowIndex].cards[cardIndex].animateAs = animation

            try? await Task.sleep(for: .seconds(2))

            player.rows[rowIndex].cards[cardIndex].shouldAnimate = false
            player.rows[rowIndex].cards[cardIndex].animateAs = nil
            
        }
    }
}
