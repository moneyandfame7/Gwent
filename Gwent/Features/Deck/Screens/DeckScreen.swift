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
    @State private var isLeaderCarouselPresented = false

    @State private var isAlertVisible = false
    private var filteredCards: [Card] {
        Card.all2.filter { $0.faction.rawValue == vm.activeTab.rawValue && $0.type != .leader }
    }

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

    private var statsView: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                DeckStatsItem(
                    title: "Total",
                    image: .Images.DeckStats.count,
                    value: "\(vm.currentDeck.cards.count)"
                )
                .frame(width: geometry.size.width / 5)

                DeckStatsItem(
                    title: "Units",
                    image: .Images.DeckStats.units,
                    value: "\(vm.currentDeck.cards.filter { $0.type == .unit }.count)/22",
                    isValid: vm.currentDeck.cards.filter { $0.type == .unit }.count >= 22
                )
                .frame(width: geometry.size.width / 5)

                DeckStatsItem(
                    title: "Specials",
                    image: .Images.DeckStats.special,
                    value: "\(vm.currentDeck.cards.filter { $0.type == .special }.count)/10",
                    isValid: true
                )
                .frame(width: geometry.size.width / 5)

                DeckStatsItem(
                    title: "Power",
                    image: .Images.DeckStats.power,
                    value: "\(vm.currentDeck.cards.reduce(0) { $0 + ($1.power ?? 0) })"
                )
                .frame(width: geometry.size.width / 5)

                DeckStatsItem(
                    title: "Heroes",
                    image: .Images.DeckStats.hero,
                    value: "\(vm.currentDeck.cards.filter { $0.type == .hero }.count)"
                )
                .frame(width: geometry.size.width / 5)
            }
        }
        .frame(height: 50)
    }

    var body: some View {
        VStack {
            VStack {
                tabsView
                Text(vm.activeTab.description)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.brandYellowSecondary)
                HStack {
                    Text("Collection")
                        .font(.headline)
                        .opacity(0.6)
                    Spacer()
                    BrandButton2(title: "Leader") {
                        vm.showLeaderPicker()
                    }
                    
                    Spacer()
                    BrandButton("Deck") {
                        vm.isDeckPresented = true
                    }
                }
                .padding(.top, 15)
                .padding(.horizontal)
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(vm.currentCollection, id: \.self) { card in
                        CardItemView(card: card) {
                            addCard(card)
                        }
                    }
                }
                .animation(.smooth, value: vm.activeTab)

                .padding(.horizontal)
            }
            .frame(maxHeight: .infinity)
//            statsView
        }
        .overlay {
            VStack {
                Button("Go to play mock") {
                    appState.navigate(to: .game(Deck.sample1))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .overlay {
            if vm.leaderCarousel != nil {
                CarouselView(
                    carousel: $vm.leaderCarousel
                )
            }
        }
        .sheet(isPresented: $vm.isDeckPresented) {
            VStack {
                HStack {
                    Image("Images/shields/\(vm.activeTab)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                    Text(vm.activeTab.title)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(vm.currentDeck.cards) { card in
                            Image("Cards/\(card.image)")
                                .resizable()
                                .scaledToFit()

                            //                                    .padding(.horizontal, 20)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
                statsView
            }
            .padding(.top)
            .background(.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func addCard(_ card: Card) {
        vm.addCard(card)
    }
}

struct DeckStatsItem: View {
    let title: String
    let image: ImageResource
    let value: String

    var isValid: Bool?

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.brandYellowSecondary)
            HStack(spacing: 0) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                Text(value)
                    .foregroundStyle(isValid != nil ? isValid! ? .green : .red : .brandYellowSecondary)
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    DeckScreen()
        .environment(\.colorScheme, .dark)
        .environment(AppState.preview)
}
