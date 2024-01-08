//
//  CardItemView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 07.01.2024.
//

import SwiftUI

/// Card item using in the grid in Deck customization.
///
struct CardItemView: View {
    let card: Card
    let action: () -> Void

    @State private var scale: CGFloat = 1

    var body: some View {
        Image("Cards/\(card.image)")
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .onTapGesture {
                Task {
                    withAnimation(.smooth(duration: 0.2)) {
                        scale = 0.9
                    }

                    try? await Task.sleep(for: .seconds(0.2))

                    withAnimation(.smooth(duration: 0.2)) {
                        scale = 1
                    }

                    action()
                }
            }
    }
}

#Preview {
    CardItemView(card: Card.leader) {
        print("Clck card")
    }
}
