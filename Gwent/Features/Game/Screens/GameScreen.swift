//
//  GameScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//
import SwiftUI

struct GameScreen: View {
    @Environment(GameViewModel.self) private var vm

    private var handView: some View {
        HStackOfCards(vm.player.hand, id: \.id) { card in
            CardView(card: card, isCompact: true, size: .extraSmall)
                .matchedGeometryEffect(id:
                    card.id,
                    in: vm.ui.namespaces.playerCards)
                .offset(y: vm.ui.isCardSelected(card) ? -25 : 0)
                .onTapGesture {
                    if vm.ui.isDisabled {
                        print("NOW IS BOT TURN, RETURN!")
                        return
                    }
                    vm.ui.selectCard(card)
                }
        }

        .frame(maxWidth: .infinity)
    }

    var body: some View {
        @Bindable var vm = vm
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                PlayerStatsView(player: vm.bot)
                    .padding(.horizontal)
            }

            .frame(maxWidth: .infinity, maxHeight: 130)
            .background(Image(.Assets.texture).resizable().rotationEffect(.degrees(180)))
            .overlay(alignment: .top) {
                HStack(spacing: -15) {
                    ForEach(vm.bot.hand) { card in
                        Image(.Assets.deckBackMonsters)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                            .matchedGeometryEffect(
                                id: card.id,
                                in: vm.ui.namespaces.botCards
                            )
                    }
                }
                .offset(y: -25)
            }

            // MARK: - board start-

            VStack(spacing: 0) {
                ForEach(vm.bot.rows, id: \.type) { row in
                    RowView(row: row, isMe: false)
                }
            }
            .frame(maxHeight: .infinity)
            /// Additional row
            HStack {
                let isSelectable = vm.ui.selectedCard?.weather != nil
                ZStack {
                    Image(systemName: "cloud.sun.rain.circle.fill")
                        .foregroundStyle(.brandYellowSecondary.opacity(0.5))

                    HStackOfCards(vm.weathers, id: \.id) { card in
                        CardView(card: card)
                            .matchedGeometryEffect(id: card.id, in: vm.ui.namespace(isMe: !card.holderIsBot!))
                    }
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
                        await vm.playCard(vm.ui.selectedCard!)
                    }
                }
            }
            .zIndex(1)
            .frame(maxWidth: .infinity, maxHeight: 75)
            .background(Image(.Assets.texture).resizable())
            .overlay(alignment: .leading) {
                TotalScoreView(
                    player: vm.bot,
                    leadingPlayer: vm.leadingPlayer,
                    currentPlayer: vm.currentPlayer
                )
            }
            .overlay(alignment: .trailing) {
                TotalScoreView(
                    player: vm.player,
                    leadingPlayer: vm.leadingPlayer,
                    currentPlayer: vm.currentPlayer
                )
            }

            VStack(spacing: 0) {
                ForEach(vm.player.rows, id: \.type) { row in
                    RowView(row: row, isMe: true)
                }
            }
            .frame(maxHeight: .infinity)

            // MARK: - board end-

            /// Hand
            ///
            VStack {
                PlayerStatsView(player: vm.player)
                    .padding()
                Spacer()
                handView
            }
            .frame(height: 200)
            .background(Image(.Assets.texture).resizable())
        }
        .ignoresSafeArea()
        .task {
            await vm.startGame()
        }
        .overlay {
            if let notification = vm.ui.notification {
                NotificationView(variant: notification)
            }

            if vm.ui.selectedCard != nil {
                CardDetailsView(selectedCard: $vm.ui.selectedCard)
            }

            if vm.ui.carousel != nil {
                CarouselView(carousel: $vm.ui.carousel)
            }
        }
        .overlay(alignment: .top) {
            let hasClearWeather = vm.weathers.contains(where: { $0.weather == .clearWeather })

            if hasClearWeather {
                ClearWeatherView()
            }
            Button("CLICK_ME") {
//                vm.en
                Task {
                    await vm.endGame()
                }

//                for i in 6 ... 7 {
//                    Task {
                ////                        withAnimation(.smooth(duration: 0.3))
//                        vm.player.hand[i].animateAs = .scorch
//                        try? await Task.sleep(for: .seconds(2))
                ////
                ////                        withAnimation(.smooth(duration: 0.3)) {
//                        vm.player.hand[i].animateAs = nil
                ////                        }
//                    }
//                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    GameScreen()
        .environment(GameViewModel.preview)
}
