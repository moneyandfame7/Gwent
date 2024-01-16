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

    var carousel: Carousel? {
        didSet {
            isDisabled = notification != nil
        }
    }

    var alert: AlertItem? {
        didSet {
            isAlertPresented = alert != nil
            isDisabled = alert != nil
        }
    }

    var isAlertPresented: Bool = false

    var selectedCard: Card?
    
    var selectedRow: Row?

    var isDisabled = false
    
    var isPassButtonDisabled = true

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
        self.carousel = carousel
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
