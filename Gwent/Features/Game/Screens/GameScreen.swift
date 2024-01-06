//
//  GameScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 05.01.2024.
//

import SwiftUI

struct GameScreen: View {
    @Environment(GameViewModel.self) private var viewModel

    private var handView: some View {
        HStackOfCards(viewModel.player.hand, id: \.id) { card in
            CardView(card: card, isCompact: true, size: .extraSmall)
                .matchedGeometryEffect(id:
                    card.id,
                    in: viewModel.ui.namespaces.playerCards)
                .offset(y: viewModel.ui.isCardSelected(card) ? -25 : 0)
                .onTapGesture {
                    if viewModel.ui.isDisabled {
                        print("NOW IS BOT TURN, RETURN!")
                        return
                    }
                    viewModel.ui.selectCard(card)
                }
        }

        .frame(maxWidth: .infinity)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                PlayerStatsView(isMe: false)
                    .padding(.horizontal)
            }

            .frame(maxWidth: .infinity, maxHeight: 130)
            .background(Image(.Assets.texture).resizable().rotationEffect(.degrees(180)))
            .overlay(alignment: .top) {
                HStack(spacing: -15) {
                    ForEach(viewModel.bot.hand) { card in
                        Image(.Assets.deckBackMonsters)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                            .matchedGeometryEffect(
                                id: card.id,
                                in: viewModel.ui.namespaces.botCards
                            )
                    }
                }
                .offset(y: -25)
            }

            // MARK: - board start-

            VStack(spacing: 0) {
                ForEach(viewModel.bot.rows, id: \.type) { row in
                    CombatRowView(row: row, isMe: false)
                }
            }
            .frame(maxHeight: .infinity)
            /// Additional row
            HStack {
                let isSelectable = viewModel.ui.selectedCard?.weather != nil
                ZStack {
                    Image(systemName: "cloud.sun.rain.circle.fill")
                        .foregroundStyle(.brandYellowSecondary.opacity(0.5))

//                    HStackOfCards(viewModel.weathers, id: \.id) { card in
//                        CardView(card: card)
//                            .matchedGeometryEffect(id: card.id, in: viewModel.ui.namespace(isMe: !card.holderIsBot!))
//                    }
                }
                .frame(width: 100)
                .frame(maxHeight: .infinity)
                .background(.black.opacity(0.5))
                .overlay {
                    if isSelectable {
                        Rectangle()
                            .fill(.brandYellow.opacity(0.3))
                            .border(.brandYellow, width: 1)
                            .shadow(color: .brandYellow, radius: 10)
                    }
                }
                .onTapGesture {
                    guard isSelectable else {
                        return
                    }
                    Task {
                        await viewModel.playCard(viewModel.ui.selectedCard!)
                    }
                }
            }
            .zIndex(1)
            .frame(maxWidth: .infinity, maxHeight: 75)
            .background(Image(.Assets.texture).resizable())
            .overlay(alignment: .leading) {
                TotalScoreView(isMe: false)
            }
            .overlay(alignment: .trailing) {
                TotalScoreView(isMe: true)
            }

            VStack(spacing: 0) {
                ForEach(viewModel.player.rows, id: \.type) { row in
                    CombatRowView(row: row, isMe: true)
                }
            }
            .frame(maxHeight: .infinity)

            // MARK: - board end-

//            Text("Game Screen")
//            Button("End Game") {
//                Task {
//                    await viewModel.endGame()
//                }
//            }
//            Button("Settings") {
//                viewModel.settings.toggleScreen()
//            }

            VStack {
                PlayerStatsView(isMe: true)
                    .padding()
                Spacer()
                handView
            }
            .frame(height: 200)
            .background(Image(.Assets.texture).resizable())
        }
        .task {
            for _ in 0 ..< 10 {
                try? await Task.sleep(for: .seconds(0.1))
                withAnimation {
                    viewModel.player.drawCard()
                    viewModel.bot.drawCard()
                }
            }

            await viewModel.startGame()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(.red, width: 5)
        .ignoresSafeArea()
        .overlay {
            if let notification = viewModel.ui.notification {
                NotificationView(variant: notification)
            }
            if viewModel.ui.selectedCard != nil {
                CardDetailsView(selectedCard: $viewModel.ui.selectedCard)
            }
        }
        .overlay(alignment: .top) {
            let hasClearWeather = viewModel.weathers.contains(where: { $0.weather == .clearWeather })

            if hasClearWeather {
                ClearWeatherView()
            }
        }
    }
}

#Preview {
    GameScreen()
        .environment(GameViewModel.preview)
}
