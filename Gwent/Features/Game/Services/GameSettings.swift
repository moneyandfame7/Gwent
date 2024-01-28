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
    class Storage {
        @AppStorage("isSoundsEnabled") var isSoundsEnabled = true
        @AppStorage("isMusicEnabled") var isMusicEnabled = true
        @AppStorage("isVibrationEnabled") var isVibrationEnabled = true
        @AppStorage("difficulty") var difficulty: Difficulty = .potato

        @AppStorage("counter") var counter = 0
    }
    
    var alert: AlertItem?

    private let storage = Storage()
    /// UI.
    private(set) var isPresented = false

    /// Settings.
    var isMusicEnabled = true {
        didSet {
            storage.isMusicEnabled = isMusicEnabled
        }
    }

    var isSoundsEnabled = true {
        didSet {
            storage.isSoundsEnabled = isSoundsEnabled
        }
    }

    var isVibrationEnabled = true {
        didSet {
            storage.isVibrationEnabled = isVibrationEnabled
        }
    }

    var difficulty: Difficulty = .potato {
        didSet {
            storage.difficulty = difficulty
        }
    }

    var counter = 0 {
        didSet {
            storage.counter = counter
        }
    }

    private init() {
        isPresented = false

        isMusicEnabled = storage.isMusicEnabled

        isSoundsEnabled = storage.isSoundsEnabled

        isVibrationEnabled = storage.isVibrationEnabled

        counter = storage.counter
    }

    func toggleScreen() {
        withAnimation {
            isPresented.toggle()
        }
    }
}

extension GameSettings {
    static let shared = GameSettings()
}
