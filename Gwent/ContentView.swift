//
//  ContentView_new.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack {
            switch appState.screen {
            case .deckCustomization:
                DeckScreen()
            case let .game(deck):
                /// зробити два ЛВЛа ( картошка, і AI ), передавати сюди
                GameRootScreen(deck: deck)
                    .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            dump(Card.all()[1])
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState.preview)
}
