//
//  CarouselView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 07.01.2024.
//

import SwiftUI

struct CarouselView: View {
    @Binding var carousel: Carousel?

    @State private var activeID: Card.ID?

    @State private var selectedCount = 0

    private let cardHeight: CGFloat = 400

    private let shadowRadius: CGFloat = 10

    private var activeCard: Card? {
        carousel?.cards.first(where: { $0.id == activeID }) ??
            carousel?.cards.first(where: { $0.id == carousel?.initID })
    }

    // MARK: Functions

    private func onClose() {
        carousel?.completion?()
        carousel = nil
    }

    private func onSelect(card: Card) {
        guard let selectAction = carousel?.onSelect else {
            return
        }

        selectAction(card)

        if let count = carousel?.count {
            selectedCount += 1

            if selectedCount >= count {
                onClose()
            }
        } else {
            onClose()
        }
    }

    // MARK: Views

    @ViewBuilder
    private func titleView(_ title: String) -> some View {
        let processedTitle = if let count = carousel?.count, count > 1 {
            "\(title) (\(selectedCount) of \(count))"
        } else {
            title
        }

        HStack(spacing: 0) {
            Text(processedTitle)
                .font(.custom("Gwent", size: 22, relativeTo: .title3))
                .textCase(.uppercase)
                .foregroundStyle(.white)
                .textBorder()
        }
        .frame(maxWidth: .infinity)
        .padding([.vertical, .horizontal])
        .padding(.bottom, 50)
    }

    @ViewBuilder
    private func itemView(card: Card) -> some View {
        let isActive = card.id == activeID
        Image("Cards/\(card.image)")
            .resizable()
            .scaledToFit()
            .frame(height: cardHeight)
            .clipShape(.rect(cornerRadius: 20))
            .containerRelativeFrame(.horizontal)
            .scrollTransition(.animated, axis: .horizontal) { content, phase in
                content
                    .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                    .brightness(phase.isIdentity ? 0 : -0.15)
            }
            .onTapGesture {
                onSelect(card: card)
            }
            .shadow(color: .brandYellow, radius: isActive ? shadowRadius : 0)
    }

    var body: some View {
        VStack(spacing: 15) {
            if let title = carousel?.title, !title.isEmpty {
                titleView(title)
            } else {
                Spacer().frame(height: 100)
            }
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(carousel?.cards ?? []) { card in
                            itemView(card: card)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $activeID, anchor: .center)
                .safeAreaPadding(.horizontal, 80)
                .frame(height: cardHeight + shadowRadius + 25)
                Spacer()
                if let activeCard {
                    AbilityView(card: activeCard)
                }
            }
            .frame(maxWidth: .infinity)

            HStack {
                if let cancelButton = carousel?.cancelButton {
                    BrandButton2(title: cancelButton) {
                        onClose()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onAppear {
            if let initID = carousel?.initID {
                activeID = initID
            } else if let firstCard = carousel?.cards.first {
                activeID = firstCard.id
            }
        }
    }
}

#Preview {
    CarouselView(carousel: .constant(Carousel.pickLeader))
        .environment(\.colorScheme, .dark)
}
