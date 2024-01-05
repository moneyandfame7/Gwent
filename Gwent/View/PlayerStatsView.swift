//
//  PlayerStatsView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import SwiftUI

struct PlayerStatsView: View {
    @Environment(AppState.self) private var appState
    let player: PlayerClass

    var body: some View {
        HStack(alignment: player.isBot ? .bottom : .top) {
            VStack(spacing: 15) {
                HStack {
                    HStack(spacing: 2) {
                        Image(.Assets.iconCardCount)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)

                        Text("\(player.hand.count)")
                            .font(.custom("Gwent", size: 24))
                            .foregroundStyle(.brandYellow)
                            .transition(.scale(scale: 1))
                    }
                    HStack(spacing: 0) {
                        Image(.Assets.emerald)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .shadow(radius: 25)

                        Image(.Assets.emerald)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .shadow(radius: 25)
                            .grayscale(0.99)
                    }
                }
//                        Spacer()
                if !player.isBot {
                    BrandButton("Pass", disabled: appState.ui.isDisabled)
                }
//                        .disabled(true)
            }
            Spacer()

            HStack {
                // TODO: isLeaderAvailable, opacity, leader preview
                CardsContainerView(iconAsset: .Assets.leaderActive) {
                    CardView(card: player.leader)
                }
                .onTapGesture {
                    if appState.ui.isDisabled {
                        return
                    }
                    appState.ui.selectCard(player.leader)
                }
                CardsContainerView(iconAsset: .Assets.discardPile) {
                    DeckOfCardsView(
                        deck: player.discard,
                        animNamespace: appState.ui.namespace(for: player),
                        isMe: !player.isBot
                    )
                }
                .onTapGesture {
                    if appState.ui.isDisabled {
                        return
                    }
                    /// appState.ui.showCarousel(cards)
                }
                DeckOfCardsView(
                    deck: player.cards,
                    faction: .scoiatael,
                    animNamespace: appState.ui.namespace(for: player),
                    isMe: !player.isBot
                )
            }
        }
    }
}

#Preview {
    VStack {
        PlayerStatsView(player: GwentModel.preview.player)
        PlayerStatsView(player: GwentModel.preview.bot)
    }
    .environment(AppState.preview)
}
