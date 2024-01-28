//
//  HapticManager.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 25.01.2024.
//

import UIKit

final class HapticManager {
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    private init() {}

    func prepare() {
        impactGenerator.prepare()
        notificationGenerator.prepare()
    }

    func trigger(_ type: HapticManager.HapticType) {
        switch type {
        case .cardSelection:
            impactGenerator.impactOccurred()
        case let .notification(notifType):
            notificationGenerator.notificationOccurred(notifType)
        }
    }
}

extension HapticManager {
    static let shared = HapticManager()

    enum HapticType {
        case cardSelection
        case notification(UINotificationFeedbackGenerator.FeedbackType)
    }
}
