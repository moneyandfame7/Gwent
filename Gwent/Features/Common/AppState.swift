//
//  AppState.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import Observation

@Observable
class AppState {
    private(set) var screen: AppScreen = .deckCustomization

    func navigate(to screen: AppScreen) {
        self.screen = screen
    }
}

extension AppState {
    static let preview = AppState()
}
