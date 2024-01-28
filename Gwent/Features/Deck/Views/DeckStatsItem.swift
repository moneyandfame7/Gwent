//
//  DeckStatsItem.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 24.01.2024.
//

import SwiftUI

struct DeckStatsItem: View {
    let title: String
    let image: ImageResource
    let value: String

    var isValid: Bool?

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.brandYellowSecondary)
            HStack(spacing: 0) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                Text(value)
                    .foregroundStyle(isValid != nil ? isValid! ? .green : .red : .brandYellowSecondary)
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    DeckStatsItem(
        title: "Total",
        image: .Images.DeckStats.count,
        value: "22"
    )
}
