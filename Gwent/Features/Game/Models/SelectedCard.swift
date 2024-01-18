//
//  SelectedCard.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 16.01.2024.
//

import Foundation

struct SelectedCard {
    let details: Card

    var isReadyToUse: Bool = false

    /// Значить що карткою можу зіграти Я, або ця картка анімується, коли її використовує бот.
    var isPlayable: Bool = true

    var holder: Tag = .bot
}

extension SelectedCard {
    static let preview: Self = SelectedCard(details: Card.leader)
}
