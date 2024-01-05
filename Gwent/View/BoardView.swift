//
//  BoardView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import SwiftUI

struct BoardView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            /// Opponent rows.
            VStack(spacing: 0) {
                ForEach(appState.model.bot.rows, id: \.type) { row in
                    CombatRowView(combatRow: row, isMe: false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            /// Additional row
            HStack {
                ZStack {
                    Image(systemName: "cloud.sun.rain.circle.fill")
                        .foregroundStyle(.brandYellowSecondary.opacity(0.5))
                }
                .frame(width: 100)
                .frame(maxHeight: .infinity)
                .background(.black.opacity(0.5))
                .overlay {
                    if appState.ui.selectedCard?.weather != nil {
                        Rectangle()
                            .fill(.brandYellow.opacity(0.3))
                            .border(.brandYellow, width: 1)
                            .shadow(color: .brandYellow, radius: 10)
                    }
                }
            }
            .zIndex(1)
            .frame(maxWidth: .infinity, maxHeight: 55)
            .background(Image(.Assets.texture).resizable())
            .overlay(alignment: .leading) {
                TotalScoreView(
                    player: appState.model.bot,
                    leadingPlayer: appState.model.leadingPlayer
                )
            }
            .overlay(alignment: .trailing) {
                TotalScoreView(
                    player: appState.model.player, leadingPlayer: appState.model.leadingPlayer
                )
            }

            /// Player rows.
            VStack(spacing: 0) {
                ForEach(appState.model.player.rows, id: \.type) { row in
                    CombatRowView(combatRow: row, isMe: true)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    BoardView()
        .environment(AppState.preview)
}
