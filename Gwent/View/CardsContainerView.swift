//
//  CardsContainerView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.12.2023.
//

import SwiftUI

struct CardsContainerView<Content: View>: View {
    var iconAsset: ImageResource
    @ViewBuilder let content: Content
    

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                content
            }
            .frame(width: 50, height: 70)
            .background(.boardBackground.opacity(0.7))
            HStack {
                Spacer().frame(width: 4)
                Image(self.iconAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .overlay {
                        Circle().stroke(
                            .brandYellowSecondary.opacity(0.2),
                            lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/
                        )
                    }
            }
            .frame(width: 22)
            .padding(1)
            .background(.boardBackground.opacity(0.7))
            .clipShape(.rect(bottomTrailingRadius: 10, topTrailingRadius: 10))
        }
    }
}

#Preview {
    CardsContainerView(iconAsset: .Assets.leaderActive) {
        Text("TEST")
    }
}
