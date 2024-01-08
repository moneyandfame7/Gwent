//
//  GameSettingsScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import SwiftUI

struct GameSettingsScreen: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        VStack {
            Text("Game Settings Screen")
                .font(.title)
            Button("Close") {
                vm.settings.toggleScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.9))
        .ignoresSafeArea()
    }
}

#Preview {
    GameSettingsScreen()
        .environment(\.colorScheme, .dark)
        .environment(GameViewModel.preview)
}
