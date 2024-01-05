//
//  HandView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 29.12.2023.
//

import SwiftUI

struct HandView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: -25) {
            ForEach(appState.model.player.hand) { card in
                let isSelected = appState.ui.isCardSelected(card)
                CardView(card: card, size: .small)
                    .offset(y: isSelected ? 0 : 25)
                    .shadow(color: .brandYellow, radius: isSelected ? 5 : 0)
                    .onTapGesture {
                        appState.ui.selectCard(card)
                    }
                    .matchedGeometryEffect(
                        id: card.id,
                        in: appState.ui.namespaces.playerCards
                    )
            }
        }
//        }
    }
}

#Preview {
    HandView()
        .environment(AppState.preview)
}
