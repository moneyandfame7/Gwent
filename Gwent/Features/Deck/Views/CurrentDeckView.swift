//
//  CurrentDeckView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 24.01.2024.
//

import SwiftUI

struct CurrentDeckView: View {
    let vm: DeckViewModel
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    @ViewBuilder
    private var statsView: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                DeckStatsItem(
                    title: "Total",
                    image: .Images.DeckStats.count,
                    value: "\(vm.deckStats.total)"
                )
                .frame(width: geometry.size.width / 5)

                
                let unitsIsValid = vm.deckStats.units >= 22
                DeckStatsItem(
                    title: "Units",
                    image: .Images.DeckStats.units,
                    value: unitsIsValid ? "\(vm.deckStats.units)" : "\(vm.deckStats.units)/22",
                    isValid: unitsIsValid
                )
                .frame(width: geometry.size.width / 5)

                
                DeckStatsItem(
                    title: "Specials",
                    image: .Images.DeckStats.special,
                    value: "\(vm.deckStats.specials)/10",
                    isValid: vm.deckStats.specials <= 10
                )
                .frame(width: geometry.size.width / 5)

                DeckStatsItem(
                    title: "Power",
                    image: .Images.DeckStats.power,
                    value: "\(vm.deckStats.power)"
                )
                .frame(width: geometry.size.width / 5)

                DeckStatsItem(
                    title: "Heroes",
                    image: .Images.DeckStats.hero,
                    value: "\(vm.deckStats.heroes)"
                )
                .frame(width: geometry.size.width / 5)
            }
        }
        .frame(height: 50)
    }

    var body: some View {
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
                        CardItemView(card: card) {
                            vm.removeCard(card)
                        }
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
}

#Preview {
    CurrentDeckView(vm: DeckViewModel.preview)
}
