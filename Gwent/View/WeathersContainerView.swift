//
//  WeathersContainerView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.12.2023.
//

import SwiftUI

struct WeathersContainerView: View {
    let cards: [Card]

    private let rect = Rect(height: 55)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(cards) { card in

                CardView(card: card, isCompact: true, rect: rect)
//                    .matchedGeometryEffect(id: card.id, in: cardNamespace)
            }
        }
        .frame(width: 91, height: 45)
        .background(.brandYellowSecondary.opacity(0.2))
    }
}

#Preview {
    WeathersContainerView(cards: Card.weathers())
}
