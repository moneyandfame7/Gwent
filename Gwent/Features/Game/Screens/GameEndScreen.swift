//
//  GameEndScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import SwiftUI

struct GameEndScreen: View {
    @Environment(AppState.self) private var appState

    @Environment(GameViewModel.self) private var vm

    var body: some View {
        VStack {
            Text("Game end Screen")

            HStack {
                Button("Restart") {
                    Task {
                        vm.restartGame()
                    }
                }

                Button("Customize deck") {
                    appState.navigate(to: .deck)
                }
            }
        }
    }
}

#Preview {
    GameEndScreen()
        .environment(AppState.preview)
        .environment(GameViewModel.preview)
}
