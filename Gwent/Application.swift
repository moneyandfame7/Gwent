//
//  GwentApp.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 20.12.2023.
//

import SwiftUI

@main
struct Application: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.colorScheme, .dark)
                .environment(appState)
        }
    }
}
