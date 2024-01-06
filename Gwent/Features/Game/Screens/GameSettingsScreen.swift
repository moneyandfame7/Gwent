//
//  GameSettingsScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import SwiftUI

struct GameSettingsScreen: View {
    @Environment(GameViewModel.self) private var viewModel
    
    var body: some View {
        VStack {
            Text("Game Settings Screen")
            Button("Close Screen") {
                viewModel.settings.toggleScreen()
            }
            .buttonStyle(.borderedProminent)
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
