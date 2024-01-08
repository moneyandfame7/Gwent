//
//  AppState.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import Foundation

@Observable
final class AppState {
    private(set) var screen: AppScreen = .deck

    func navigate(to screen: AppScreen) {
        self.screen = screen
    }
}

extension AppState {
    static let preview = AppState()
}
