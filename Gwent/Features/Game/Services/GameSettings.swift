//
//  GameSettings.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import Observation
import SwiftUI

@Observable
class GameSettings {
    private(set) var isPresented = false
    private(set) var isSoundMuted = false
    private(set) var isMusicMuted = false

    func toggleScreen() {
        withAnimation {
            isPresented.toggle()
        }
    }
}

extension GameSettings {
    static let preview = GameSettings()
}
