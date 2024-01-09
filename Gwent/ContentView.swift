//
//  ContentView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 20.12.2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack {
            switch appState.screen {
            case .deck:
                DeckScreen()
            case let .game(deck):
                // game(deck, difficulty)
                GameRootScreen(deck: deck)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.colorScheme, .dark)
        .environment(AppState.preview)
}
