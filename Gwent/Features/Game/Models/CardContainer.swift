//
//  CardContainer.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 07.01.2024.
//

import Foundation

enum CardContainer {
    /// Я хз, краще передавати Row (struct), чи Card.Row(enum)?
    case row(Card.Row)
    case discard
    case hand
    case deck
    case weathers
}
