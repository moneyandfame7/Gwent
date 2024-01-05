//
//  CardDeckView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.12.2023.
//

import SwiftUI

struct DeckOffset {
    var x: CGFloat
    var y: CGFloat

    var coefficient: Double

    init(total: Int, index: Int, coefficient: Double = 1.1) {
        self.coefficient = coefficient
        let offset = CGFloat(total - index)
        x = offset * self.coefficient
        y = x
    }
}

struct DeckOfCardsView: View {
    var deck: [Card] = []
    var faction: Card.Faction?
    var animNamespace: Namespace.ID
    var isMe: Bool

    private var imageAssetName: String? {
        guard let faction, faction != .neutral else {
            return nil
        }

        return "Assets/deck_back_\(faction.rawValue)"
    }

    var body: some View {
        ZStack {
            ForEach(deck.indices, id: \.self) { i in
                let offset = DeckOffset(total: deck.count, index: i, coefficient: 0.3)

                Group {
                    if let imageAssetName {
                        Image(imageAssetName)
                            .resizable()
                    } else {
                        CardView(card: deck[i])
                    }
                }
                .matchedGeometryEffect(
                    id: deck[i].id,
                    in: animNamespace
                )
                .offset(x: offset.x, y: offset.y)
                .shadow(radius: 1)
            }
            .offset(x: -2, y: -2)
        }
        .frame(width: 50, height: 70)
        .background(.boardBackground.opacity(0.7))
        .overlay(alignment: .bottom) {
            Text("\(deck.count)")
//                .scaledToFit()
                .minimumScaleFactor(0.01)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.brandYellowSecondary)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.black.opacity(0.6))
        }
    }
}

#Preview {
    VStack {
        DeckOfCardsView(
            deck: Array(Card.all2[0 ... 25]),
            faction: nil,
            animNamespace: AppState.preview.ui.namespaces.playerCards,
            isMe: true
        )
        DeckOfCardsView(
            deck: Array(Card.all2[0 ... 25]),
            faction: .monsters,
            animNamespace: AppState.preview.ui.namespaces.botCards,
            isMe: true
        )
    }
}
