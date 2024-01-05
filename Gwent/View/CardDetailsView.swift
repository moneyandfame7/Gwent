//
//  CardDetailsView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

/// якщо це картка лідера, то не буде isReadyForUse, треба натиснути на саму картку і вона заюзається, потім повернеться
/// на місце.
struct CardDetailsView: View {
//    @State private var isReadyForUse = false
    @Binding var selectedCard: Card?

    @State private var isReadyToUse = false

    var body: some View {
        VStack(spacing: 25) {
            CardView(
                card: selectedCard!,
                isCompact: isReadyToUse,
                size: isReadyToUse ? .small : .large
            )
            .overlay(alignment: .topTrailing) {
                HStack {
                    if selectedCard?.type == .leader {
                        IconButton(systemName: "gamecontroller.fill") {}
                            .scaleEffect(isReadyToUse ? 0 : 1)
                    }

                    IconButton(systemName: "xmark") {
                        selectedCard = nil
                    }
                    .opacity(isReadyToUse ? 0 : 1)
                }
                .offset(x: -10, y: 10)
            }

            .onTapGesture {
                if selectedCard?.type == .leader {
                    print("should play instantly")
                } else {
                    withAnimation(.smooth(duration: 0.3)) {
                        isReadyToUse.toggle()
                    }
                }
            }
            .offset(x: isReadyToUse ? 150 : 0)
            .shadow(color: .brandYellow, radius: 25)

            if let ability = selectedCard!.ability, !isReadyToUse {
                if let info = Ability.all[ability.rawValue] {
                    VStack {
                        HStack {
                            Text(info.name.capitalized)
                                .font(.title2)
                                .fontWeight(.heavy)
                        }
//                        Spacer()
                        Text(info.description)
                            .multilineTextAlignment(.center)
                            .padding(.vertical)
                    }
                    .overlay(alignment: .topLeading) {
                        Image("Abilities/\(ability.rawValue)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .padding()

                    .frame(minHeight: 100)
                    .frame(maxWidth: .infinity)
                    .background(.black.opacity(0.8))
                }
            }
        }
        .foregroundStyle(.brandYellowSecondary)
    }
}

#Preview {
    CardDetailsView(
        selectedCard: .constant(.all2[3])
    )
}