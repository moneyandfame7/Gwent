//
//  CoinView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 04.01.2024.
//

import SwiftUI

struct CoinView: View {
    let asset: ImageResource
    @State private var degrees: CGFloat = 0

    var body: some View {
        Image(asset)
            .resizable()
            .scaledToFit()
            .frame(height: 140)
            .rotation3DEffect(
                .degrees(degrees),
                axis: (x: 0, y: 1.0, z: 0.0)
            )
            .onAppear {
                withAnimation(.smooth(duration: 0.8)) {
                    degrees = 360 * 3
                }
            }
    }
}

#Preview {
    CoinView(asset: .Images.Notifications.coinMe)
}
