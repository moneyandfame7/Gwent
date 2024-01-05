//
//  SelectedCard.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import Foundation

struct SelectedCard {
    var details: Card? {
        willSet {
            self.isReadyToUse = false
        }
    }

    var isReadyToUse = false
}
