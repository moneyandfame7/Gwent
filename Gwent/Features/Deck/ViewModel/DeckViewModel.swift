//
//  DeckViewModel.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import Observation

@Observable
class DeckViewModel {
    var deck: Deck = .sample2()

    var count = 0

    deinit {
        print("DeckViewModel <-- Deinit -->")
    }
}
