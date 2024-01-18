//
//  GameUI.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import Observation
import SwiftUI

struct Namespaces {
    let playerCards: Namespace.ID = Namespace().wrappedValue
    let botCards: Namespace.ID = Namespace().wrappedValue
    let weatherCards: Namespace.ID = Namespace().wrappedValue
}

@Observable
final class GameUI {
    let namespaces = Namespaces()

    var notification: Notification? {
        didSet {
            if notification != nil {
                isDisabled = true
            }
        }
    }

    var carousel: Carousel?

    var alert: AlertItem?

    var selectedCard: SelectedCard?

    var selectedRow: Row?

    var isDisabled = true

    var isPassButtonDisabled = true

    func selectCard(_ card: Card, holder: Tag = .me) -> Void {
        if selectedCard?.details.id == card.id {
            selectedCard = nil
        } else {
            selectedCard = SelectedCard(details: card, holder: holder)
        }
    }

    @MainActor
    /// Ця функція використовується перед самим застосуванням картки.
    /// Якщо це бот, то потрібно показувати картку, а якщо Я - дія з карткою залежить від її типу.
    func animateCardUsage(_ card: Card, holder: Tag) async {
        if holder == .bot {
            selectCard(card, holder: .bot)

            try? await Task.sleep(for: .seconds(0.5))

            withAnimation(.smooth(duration: 0.3)) {
                selectedCard?.isReadyToUse = true
            }

            try? await Task.sleep(for: .seconds(1))
        } else if card.type == .leader || card.type == .special && card.ability == .scorch {
            withAnimation(.smooth(duration: 0.3)) {
                selectedCard?.isReadyToUse = true
            }
            try? await Task.sleep(for: .seconds(0.7))

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.3))
                selectedCard = nil
            }
        }

        selectedCard = nil
    }

    func isCardSelected(_ card: Card) -> Bool {
        return card.id == selectedCard?.details.id
    }

    @MainActor
    func showNotification(_ notification: Notification) async -> Void {
        let duration = notification == .coinMe || notification == .coinOp ? 2 : 1.5

        if self.notification != nil {
            try? await Task.sleep(for: .seconds(duration))
        }

        withAnimation {
            self.notification = notification
        }

        try? await Task.sleep(for: .seconds(duration))

        withAnimation {
            self.notification = nil
        }

        try? await Task.sleep(for: .seconds(1))
    }

    func showCarousel(_ carousel: Carousel) {
        withAnimation {
            self.carousel = carousel
        }
    }

    func showAlert(_ alert: AlertItem) {
        self.alert = alert
    }

    func namespace(for player: Player) -> Namespace.ID {
        return player.isBot ? namespaces.botCards : namespaces.playerCards
    }

    func namespace(isMe: Bool) -> Namespace.ID {
        return isMe ? namespaces.playerCards : namespaces.botCards
    }

//    func theMegaPuperTestFunction() {
//        let group = DispatchGroup()
//        var value: Int?
//
//    }
}
