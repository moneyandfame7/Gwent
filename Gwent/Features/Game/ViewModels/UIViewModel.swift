//
//  UIViewModel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import Observation
import SwiftUI

@Observable
class UIViewModel {
    let namespaces = Namespaces()

    private(set) var notification: Notification?

    private(set) var isDisabled = false

    var selectedCard: Card?

    func namespace(for player: Player) -> Namespace.ID {
        return player.isBot ? namespaces.botCards : namespaces.playerCards
    }

    func namespace(isMe: Bool) -> Namespace.ID {
        return isMe ? namespaces.playerCards : namespaces.botCards
    }

    func showNotification(_ notification: Notification) async {
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

    func disable(_ value: Bool) {
        isDisabled = value
    }

    func dismissSelectedCard() {
        selectedCard = nil
    }

    func selectCard(_ card: Card) -> Void {
        print(card.id)
        if selectedCard?.id == card.id {
            selectedCard = nil
        } else {
            selectedCard = card
        }
    }

    func isCardSelected(_ card: Card) -> Bool {
        return card.id == selectedCard?.id
    }

    @MainActor
    func animateCard(_ card: Card, as animation: Card.Animation? = nil) async {
        card.shouldAnimate = true
        card.animateAs = animation

        try? await Task.sleep(for: .seconds(2))

        card.shouldAnimate = false
        card.animateAs = nil
    }
}
