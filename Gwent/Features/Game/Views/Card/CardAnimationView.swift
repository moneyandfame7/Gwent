//
//  CardAnimationView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 04.01.2024.
//

import SwiftUI

struct CardAnimationView: View {
//    @Environment(GameViewModel.self) private var vm

    let card: Card
    @State private var scale: CGFloat = 0
    @State private var opacity: CGFloat = 0

    private var imageName: String {
        if card.ability == .scorch && card.animateAs == nil {
            return ""
        }

        if let source = card.animateAs?.imageSource ?? card.ability?.rawValue {
            return "Images/card_effects/\(source)"
        }
        return ""
    }

    @ViewBuilder
    private var heroView: some View {
        Image(.Images.CardEffects.hero)
            .resizable()
            .opacity(opacity)
    }

    private func animate() async {
        if let ability = card.ability {
//           sound here????
        }
        withAnimation(.card) {
            opacity = 1
        }

        try? await Task.sleep(for: .card)

        withAnimation(.card) {
            scale = 1
        }

        try? await Task.sleep(for: .card)

        withAnimation(.card) {
            scale = 0.8
        }

        try? await Task.sleep(for: .seconds(1))

        withAnimation(.card) {
            scale = 0.4

            opacity = 0
        }
    }

    @ViewBuilder
    private func animateAsView(_ animation: Card.Animation) -> some View {
        switch animation {
        case .scorch:
            Image(imageName)
                .resizable()
                .scaledToFill()
                .opacity(opacity)
        case .medic:
            ZStack {
                Image(.Images.CardEffects.medicGreen)
                    .resizable()
                    .scaledToFit()
                    .brightness(-0.4)
                    .opacity(opacity)
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
        case let .tightBond(multiplier):
            VStack(alignment: .center) {
                Text("x\(multiplier)")
                    .foregroundStyle(.brandGreen)
                    .fontWeight(.bold)
                    .font(.title2)
                    .padding(.horizontal, 2)
                    .textBorder()
                    .offset(x: -6)
                    .opacity(opacity)
                    .scaleEffect(scale)

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
        }
    }

    var body: some View {
        ZStack {
            if let animateAs = card.animateAs {
                animateAsView(animateAs)
            } else if card.type == .hero {
                heroView
            } else if card.ability == .spy {
                ZStack {
                    heroView
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .opacity(opacity)
                        .scaleEffect(scale)
                }
            } else if !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
        }
        .task {
            await animate()
//            appState.
        }
    }
}

#Preview {
    VStack {
        CardView(card: Card.all2[22], isPlayable: true)
            .overlay {
                CardAnimationView(card: Card.all2[22])
            }
    }
}
