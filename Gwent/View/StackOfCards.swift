//
//  StackOfCards.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

struct StackOfCards:  View {
    @Environment(AppState.self) private var appState
    let cards: [Card]

    private let cardRect: Rect
    var n: Int {
        cards.count
    }

    var overlapCount: Int
    var isMe: Bool
    

    init(cards: [Card], size: Rect.Size, overlapCount: Int = 6, isMe: Bool) {
        self.cards = cards
        cardRect = Rect(size: size)

        self.overlapCount = overlapCount
        self.isMe = isMe
    }

    var body: some View {
        GeometryReader { geometry in

            HStack(spacing: calculateSpacing(geometry)) {
                ForEach(cards) { card in

                    CardView(card: card, isCompact: true, rect: cardRect)
                        .matchedGeometryEffect(
                            id: card.id,
                            in: appState.ui.namespace(isMe: isMe)
                        )
                }
            }
            // обовʼязково, щоб картки по центру були
            .frame(maxWidth: .infinity, maxHeight: .infinity)

//            .frame(height: geometry.size.height)
        }
    }

    /// https://github.com/asundr/gwent-classic/blob/db0ca45b26ed50f032000ce92f3d36ae6a102a9e/gwent.js#L740C8-L740C8
    func calculateSpacing(_ geometry: GeometryProxy) -> CGFloat {
        let floatN = CGFloat(n)
        let firstV = geometry.size.width - (cardRect.width * floatN)
        let secondV = (2 * floatN) - (1.05 * floatN)
        let result = n <= overlapCount ? 0 : firstV / secondV

        return result
    }
}

#Preview {
    VStack(spacing: 0) {
        HStack {
            Rectangle().fill(.brandYellow).frame(width: 50, height: 65)
            StackOfCards(
                cards: Array(Card.all2[0 ..< 3]),
                size: .extraSmall,

                isMe: true
            )
        }

        VStack {
            StackOfCards(
                cards: Array(Card.all2[3 ..< 8]),
                size: .small,

                overlapCount: 5,
                isMe: true
            )
        }

        VStack {
            StackOfCards(
                cards: Array(Card.all2[8 ..< 15]),
                size: .medium,

                isMe: true
            )
        }
    }
    .environment(AppState.preview)
}
