//
//  GameEndScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import SwiftUI

struct GameEndScreen: View {
    @Environment(AppState.self) private var appState
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        VStack {
            Text("Game End Screen!")

            HStack {
                Button("Restart") {
                    Task {
                        viewModel.restartGame()
                    }
                }

                Button("Customize deck") {
                    appState.navigate(to: .deckCustomization)
//                    viewModel.reset()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.9))
        .foregroundStyle(.brandYellowThird)
    }
}

#Preview {
    GameEndScreen()
        .environment(AppState.preview)
        .environment(GameViewModel.preview)
}
