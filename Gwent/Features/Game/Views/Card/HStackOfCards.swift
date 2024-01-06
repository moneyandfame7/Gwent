//
//  HStackOfCards.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 02.01.2024.
//

import SwiftUI

struct HStackOfCards<Data: RandomAccessCollection, Content: View, ID: Hashable>: View {
    let data: Data
    var id: KeyPath<Data.Element, ID>
    let offset: CGFloat
    var content: (Data.Element) -> Content
    private var n: Int {
        data.count
    }

    private let cardRect: Rect

    init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        offset: CGFloat = 1.05,
        size: Rect.Size = .extraSmall,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.offset = offset
        cardRect = Rect(size: size)
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            let spacing = calculateSpacing(geometry)
            HStack(spacing: spacing) {
                ForEach(data, id: id, content: content)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          
        }
        .frame(maxHeight: cardRect.height)
    }

    /// https://github.com/asundr/gwent-classic/blob/db0ca45b26ed50f032000ce92f3d36ae6a102a9e/gwent.js#L740C8-L740C8
    private func calculateSpacing(_ geometry: GeometryProxy) -> CGFloat {
//        print("CURRENT: \(CGFloat(n) * cardRect.width), TOTAL: \(geometry.size.width)")

        let floatN = CGFloat(n)

        let currentWidth = floatN * cardRect.width

        let firstV = geometry.size.width - (cardRect.width * floatN)
        let secondV = (2 * floatN) - (offset * floatN)
        let result = currentWidth <= geometry.size.width ? 0 : firstV / secondV

        return result
    }
}

extension HStackOfCards {
    init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        offset: CGFloat = 1.05,
        height: CGFloat,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.offset = offset
        cardRect = Rect(height: height)

        self.content = content
    }
}

#Preview {
    HStackOfCards(Card.inHand(), id: \.id, size: .small) { card in
        CardView(card: card, size: .small)
    }
}
