//
//  DeckScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import SwiftUI

struct DeckScreen: View {
    @Environment(AppState.self) private var appState

    @State private var vm = DeckViewModel()

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    @ViewBuilder
    private var tabsView: some View {
        GeometryReader { geometry in
            HStack {
                Button(vm.prevTab.title) {
                    vm.selectPrevTab()
                }
                .font(.subheadline)
                .tint(.brandBrown)

                Spacer()
                VStack(spacing: 0) {
                    HStack {
                        Image("Images/shields/\(vm.activeTab)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                        Text(vm.activeTab.title)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    HStack {
                        ForEach(FactionTab.allCases, id: \.self) { tab in
                            Rectangle()
                                .fill(tab == vm.activeTab ? .brandYellow.opacity(0.6) : .white.opacity(0.3))
                                .rotationEffect(.degrees(45))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
                .frame(width: geometry.size.width / 2)
                Spacer()
                Button(vm.nextTab.title) {
                    vm.selectNextTab()
                }
                .tint(.brandBrown)
                .font(.subheadline)
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 50)
    }

    var body: some View {
        VStack {
            VStack {
                tabsView
                Text(vm.activeTab.description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.brandYellowSecondary)
                HStack {
//                    Spacer()
                    BrandButton2(title: "Leader") {
                        vm.showLeaderPicker()
                    }
                    Spacer()
                    BrandButton2(title: "Start Game") {
                        vm.startGame {
                            appState.navigate(to: .game(vm.currentDeck))
                        }
                    }

                    Spacer()
                    BrandButton2(title: "Deck") {
                        vm.isDeckPresented = true
                    }
                }
                .padding(.top, 15)
                .padding(.horizontal)
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(vm.currentCollection) { card in
                        CardItemView(card: card) {
                            vm.addCard(card)
                        }
                    }
                }
//                .animation(.smooth, value: vm.activeTab)
                .padding(.horizontal)
                .sensoryFeedback(.impact(weight: .medium), trigger: vm.currentCollection)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay {
            VStack {
                Button("Go to play mock") {
                    appState.navigate(to: .game(Deck.sample1))
                }
                .buttonStyle(.borderedProminent)
            }

            if vm.leaderCarousel != nil {
                CarouselView(carousel: $vm.leaderCarousel)
            }
        }
        .sheet(isPresented: $vm.isDeckPresented) {
            CurrentDeckView(vm: vm)
        }
        .background(.black)
        .toast(text: $vm.toast)
    }
}

#Preview {
    DeckScreen()
        .environment(\.colorScheme, .dark)
        .environment(AppState.preview)
}
