//
//  ContentView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 20.12.2023.
//

import SwiftUI

struct ContentView_deprecated: View {
//    @Environment(AppState.self) private var appState
//
//    private var handView: some View {
//        HStackOfCards(appState.model.player.hand, id: \.id) { card in
//            CardView(card: card, isCompact: true, size: .extraSmall)
//                .matchedGeometryEffect(id:
//                    card.id,
//                    in: appState.ui.namespaces.playerCards)
//                .offset(y: appState.ui.isCardSelected(card) ? -25 : 0)
//                .onTapGesture {
//                    if appState.ui.isDisabled {
//                        print("NOW IS BOT TURN, RETURN!")
//                        return
//                    }
//                    appState.ui.selectCard(card)
//                }
//        }
//
//        .frame(maxWidth: .infinity)
//    }
//
//    var body: some View {
//        @Bindable var appState = appState
//        VStack(spacing: 0) {
//            VStack(spacing: 0) {
//                Spacer()
//                PlayerStatsView(player: appState.model.bot)
//                    .padding(.horizontal)
//            }
//
//            .frame(maxWidth: .infinity, maxHeight: 130)
//            .background(Image(.Assets.texture).resizable().rotationEffect(.degrees(180)))
//            .overlay(alignment: .top) {
//                HStack(spacing: -15) {
//                    ForEach(appState.model.bot.hand) { card in
//                        Image(.Assets.deckBackMonsters)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 70)
//                            .matchedGeometryEffect(
//                                id: card.id,
//                                in: appState.ui.namespaces.botCards
//                            )
//                    }
//                }
//                .offset(y: -25)
//            }
//
//            // MARK: - board start-
//
//            VStack(spacing: 0) {
//                ForEach(appState.model.bot.rows, id: \.type) { row in
//                    CombatRowView(combatRow: row, isMe: false)
//                }
//            }
//            .frame(maxHeight: .infinity)
//            /// Additional row
//            HStack {
//                let isSelectable = appState.ui.selectedCard?.weather != nil
//                ZStack {
//                    Image(systemName: "cloud.sun.rain.circle.fill")
//                        .foregroundStyle(.brandYellowSecondary.opacity(0.5))
//
//                    HStackOfCards(appState.model.weathers, id: \.id) { card in
//                        CardView(card: card)
//                            .matchedGeometryEffect(id: card.id, in: appState.ui.namespace(isMe: !card.holderIsBot!))
//                    }
//                }
//                .frame(width: 100)
//                .frame(maxHeight: .infinity)
//                .background(.black.opacity(0.5))
//                .overlay {
//                    if isSelectable {
//                        Rectangle()
//                            .fill(.brandYellow.opacity(0.3))
//                            .border(.brandYellow, width: 1)
//                            .shadow(color: .brandYellow, radius: 10)
//                    }
//                }
//                .onTapGesture {
//                    guard isSelectable else {
//                        return
//                    }
//                    Task {
//                        await appState.model.playCard(appState.ui.selectedCard!)
//                    }
//                }
//            }
//            .zIndex(1)
//            .frame(maxWidth: .infinity, maxHeight: 75)
//            .background(Image(.Assets.texture).resizable())
//            .overlay(alignment: .leading) {
//                TotalScoreView(
//                    player: appState.model.bot,
//                    leadingPlayer: appState.model.leadingPlayer,
//                    currentPlayer: appState.model.currentPlayer
//                )
//            }
//            .overlay(alignment: .trailing) {
//                TotalScoreView(
//                    player: appState.model.player,
//                    leadingPlayer: appState.model.leadingPlayer,
//                    currentPlayer: appState.model.currentPlayer
//                )
//            }
//
//            VStack(spacing: 0) {
//                ForEach(appState.model.player.rows, id: \.type) { row in
//                    CombatRowView(combatRow: row, isMe: true)
//                }
//            }
//            .frame(maxHeight: .infinity)
//
//            // MARK: - board end-
//
//            /// Hand
//            ///
//            VStack {
//                PlayerStatsView(player: appState.model.player)
//                    .padding()
//                Spacer()
//                handView
//            }
//            .frame(height: 200)
//            .background(Image(.Assets.texture).resizable())
//        }
//        .ignoresSafeArea()
//        .task { /*@MainActor in*/
//            
////                try await Task.sleep(for: .seconds(3))
//
//                Task(priority: .background) {
//                    SoundManager.shared.playSound2(sound: .deck)
//                }
//
//                for _ in 0 ..< 10 {
//                    try? await Task.sleep(for: .seconds(0.1))
//                    withAnimation(.smooth(duration: 0.3)) {
//                        appState.model.player.pickFromCards()
//                        appState.model.bot.pickFromCards()
//                    }
//                }
//                /// бо якісь пролаги коли монетка анімується
//                try? await Task.sleep(for: .seconds(0.5))
//
//                await appState.model.startGame()
//
//         
//        }
//        .overlay {
//            if let notification = appState.ui.notification {
//                NotificationView(variant: notification)
//            }
//
//            if appState.ui.selectedCard != nil {
//                CardDetailsView(selectedCard: $appState.ui.selectedCard)
//            }
//        }
//        .overlay(alignment: .top) {
//            let hasClearWeather = appState.model.weathers.contains(where: { $0.weather == .clearWeather })
//
//            if hasClearWeather {
//                ClearWeatherView()
//            }
//            Button("CLICK_ME") {
//                for i in 6 ... 7 {
//                    Task {
////                        withAnimation(.smooth(duration: 0.3))
//                        appState.model.player.hand[i].animateAs = .scorch
//                        try? await Task.sleep(for: .seconds(2))
//                        
//                        withAnimation(.smooth(duration: 0.3)) {
//                            appState.model.player.hand[i].animateAs = nil
//                        }
//                    }
//                }
//            }
//            .buttonStyle(.borderedProminent)
//        }
//    }
    var body: some View {
        Text("Content_View_deprecated")
    }
}

#Preview {
    ContentView_deprecated()
        .environment(\.colorScheme, .dark)
        .environment(AppState.preview)
}
