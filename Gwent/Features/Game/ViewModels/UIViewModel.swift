//
//  UIViewModel.swift
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
final class UIViewModel {
    static let preview = UIViewModel()
    let namespaces = Namespaces()

    var notification: Notification?

    var carousel: Carousel?

    var selectedCard: Card?
    var selectedRow: Row?

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

//    @MainActor
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

    func showCarousel(_ carousel: Carousel) {
        self.carousel = carousel
    }

    func namespace(for player: Player) -> Namespace.ID {
        return player.isBot ? namespaces.botCards : namespaces.playerCards
    }

    func namespace(isMe: Bool) -> Namespace.ID {
        return isMe ? namespaces.playerCards : namespaces.botCards
    }
}
