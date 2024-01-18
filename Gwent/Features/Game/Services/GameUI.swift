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
            isDisabled = notification != nil
        }
    }

    var carousel: Carousel?

    var alert: AlertItem?

    var selectedCard: SelectedCard?

    var selectedRow: Row?

    var isDisabled = false

    var isPassButtonDisabled = true

    func selectCard(_ card: Card, holder: Tag = .me) -> Void {
        if selectedCard?.details.id == card.id {
            selectedCard = nil
        } else {
            selectedCard = SelectedCard(details: card, holder: holder)
        }
    }

    func isCardSelected(_ card: Card) -> Bool {
        return card.id == selectedCard?.details.id
    }

    @MainActor
    func showNotification(_ notification: Notification) async -> Void {
        withAnimation {
            self.notification = notification
        }

        let duration = notification == .coinMe || notification == .coinOp ? 2 : 1.5

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
