//
//  PlayerStatsView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import SwiftUI

struct PlayerStatsView: View {
    @Environment(GameViewModel.self) private var viewModel: GameViewModel


    let isMe: Bool

    private var player: Player {
        viewModel.getPlayer(isBot: !isMe)
    }

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
                    BrandButton("Pass", disabled: viewModel.ui.isDisabled)
                }
//                        .disabled(true)
            }
            Spacer()

            HStack {
                // TODO: isLeaderAvailable, opacity, leader preview
                CardsContainerView(iconAsset: .Assets.leaderActive) {
                    CardView(card: player.deck.leader)
                }
                .onTapGesture {
                    if viewModel.ui.isDisabled {
                        return
                    }
                    viewModel.ui.selectCard(player.deck.leader)
                }
                CardsContainerView(iconAsset: .Assets.discardPile) {
                    DeckOfCardsView(
                        deck: player.discardPile,
                        animNamespace: viewModel.ui.namespace(isMe: isMe),
                        isMe: isMe
                    )
                }
                .onTapGesture {
                    if viewModel.ui.isDisabled {
                        return
                    }
                    /// appState.ui.showCarousel(cards)
                }
                DeckOfCardsView(
                    deck: player.deck.cards,
                    faction: .scoiatael,
                    animNamespace: viewModel.ui.namespace(isMe: isMe),
                    isMe: isMe
                )
            }
        }
    }
}

#Preview {
    VStack {
        PlayerStatsView(isMe: false)
        Spacer()
        PlayerStatsView(isMe: true)

    }
    .environment(GameViewModel.preview)
}
