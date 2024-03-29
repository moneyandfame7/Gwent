//
//  GameRootScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import SwiftUI

struct GameRootScreen: View {
    @Environment(AppState.self) private var appState
    let deck: Deck

    @State private var vm: GameViewModel

    init(deck: Deck) {
        self.deck = deck
        vm = GameViewModel(deck: deck)
    }

    var body: some View {
        ZStack {
            GameScreen()

            if vm.isGameOver {
                GameEndScreen()
                    .zIndex(1)
                    .transition(.move(edge: .bottom))
            }

            if vm.settings.isPresented {
                GameSettingsScreen()
                    .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(vm)
        .overlay {
            Button("GO deck") {
                appState.navigate(to: .deck)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    GameRootScreen(deck: Deck.sample1)

        // MARK: обовʼязково, бо в GameEndScreen юзаю його і крашиться без цього

        .environment(AppState.preview)
}
