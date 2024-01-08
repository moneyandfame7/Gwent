//
//  CarouselView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 07.01.2024.
//

import SwiftUI

struct CarouselView: View {
    @Binding var carousel: Carousel?
    @State private var currentScrollID: Card.ID? = Card.inHand.count / 2

    private var currentCard: Card {
        Card.all2.first { $0.id == currentScrollID }!
    }

    var body: some View {
        VStack(spacing: 15) {
            if !carousel!.title.isEmpty {
                HStack {
                    Spacer()
                    Text(carousel!.title)
                        .font(.headline)
                    //                    .fontWeight(.head)
                    //                    .font(.title3)
                    Spacer()
                    IconButton(systemName: "xmark") {
                        carousel = nil
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.black.opacity(0.8))
                .padding(.top, 65)
                .foregroundStyle(.brandYellowSecondary)
            } else {
                Spacer().frame(height: 105)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(carousel!.cards) { card in
                        let isActive = currentScrollID == card.id
                        Image("Cards/\(card.image)")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 450)
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            .overlay {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(.brandYellow.gradient, lineWidth: isActive ? 4 : 0)
                            }
                            .shadow(
                                color: .brandYellow,
                                radius: isActive ? 10 : 0
                            )
                            .containerRelativeFrame(.horizontal)
                            .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                content
                                    .brightness(phase.isIdentity ? 0 : 0.1)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                            }
                            .id(card.id)
                            .onTapGesture {
                                carousel?.action(card)
                                print("#\(card.id)")
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $currentScrollID)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 65)
            .frame(height: 460)

            if let ability = currentCard.ability, let abilityInfo = Ability.all[ability.rawValue] {
                VStack {
                    HStack {
                        Text(abilityInfo.name.capitalized)
                            .font(.title2)
                            .fontWeight(.heavy)
                    }
                    //                        Spacer()
                    Text(abilityInfo.description)
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                }
                .overlay(alignment: .topLeading) {
                    Image("Abilities/\(ability.rawValue)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .padding(8)
                .frame(minHeight: 100)
                .frame(maxWidth: .infinity)
                .background(.black.opacity(0.8))
                .foregroundStyle(.brandYellowSecondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        .background(Color.gray.opacity(0.4).onTapGesture {
            print("CLick background")
        })
        .ignoresSafeArea()
    }
}

#Preview {
    CarouselView(
        carousel: .constant(Carousel.preview)
    )
}
