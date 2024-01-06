//
//  GameRootScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import SwiftUI

struct GameRootScreen: View {
    let deck: Deck

    @State private var viewModel: GameViewModel

    init(deck: Deck) {
        self.deck = deck
        viewModel = GameViewModel(deck: deck)
//        _viewModel = State(initialValue: GameViewModel(deck: deck))
    }

    var body: some View {
        ZStack {
            GameScreen()

            if viewModel.isGameOver {
                GameEndScreen()
                    .zIndex(1)
                    .transition(.move(edge: .bottom))
            }

            if viewModel.settings.isPresented {
                GameSettingsScreen()
                    .transition(.move(edge: .bottom))
            }
        }

//        .ignoresSafeArea()
        .environment(viewModel)
    }
}

#Preview {
    GameRootScreen(deck: Deck.sample())

        // MARK: обовʼязково, бо в GameEndScreen юзаю його і крашиться без цього

        .environment(AppState.preview)
}
