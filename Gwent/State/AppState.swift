//
//  AppState.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import Foundation

@Observable
final class AppState {
    static let preview = AppState()
    var ui: UIManager
    let model: GwentModel

    init() {
        let uiManager = UIManager()

        ui = uiManager
        model = GwentModel(ui: uiManager)
    }
}
