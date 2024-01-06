//
//  DeckCustomization.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import SwiftUI

struct DeckScreen: View {
    @Environment(AppState.self) private var appState

    private var viewModel = DeckViewModel()
    var body: some View {
        VStack {
            Text("DeckScreen")
            Button("Start game") {
                appState.navigate(to: .game(viewModel.deck))
            }
        }
    }
}

#Preview {
    DeckScreen()
        .environment(AppState.preview)
}
