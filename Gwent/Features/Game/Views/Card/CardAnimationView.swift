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
        if let source = card.animateAs?.rawValue ?? card.ability?.rawValue {
            return "Images/card_effects/\(source)"
        }
        return ""
    }

    @ViewBuilder
    private var hero: some View {
        Image(.Images.CardEffects.hero)
            .resizable()
//            .scaledToFill()
//        Image(.Images.CardEffects.hero)
//            .resizable()
        ////            .scaledToFill()
//            .offset(y: -20)
//            .rotationEffect(.degrees(90))
    }

    private func animate() async {
        if let ability = card.ability {
//           sound here????
        }
        withAnimation(.smooth(duration: 0.3)) {
            opacity = 1
        }

        try? await Task.sleep(for: .seconds(0.3))

        withAnimation(.smooth(duration: 0.3)) {
            scale = 1
        }

        try? await Task.sleep(for: .seconds(0.3))

        withAnimation(.smooth(duration: 0.3)) {
            scale = 0.8
        }

        try? await Task.sleep(for: .seconds(1))

        withAnimation(.smooth(duration: 0.3)) {
            scale = 0.4

            opacity = 0
        }
    }

    var body: some View {
        ZStack {
            if card.type == .hero {
                hero
                    .opacity(opacity)
            } else if card.animateAs == .scorch {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .opacity(opacity)

            } else if card.animateAs == .medic {
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
            } else if card.ability == .spy {
                ZStack {
                    hero
                        .opacity(opacity)
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .opacity(opacity)
                        .scaleEffect(scale)
                }
            } else if card.ability == .tightBond {
                VStack(alignment: .center) {
                    Text("x2")
                        .foregroundStyle(.brandGreen)
                        .fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/)
                        .font(.title2)
                        .padding(.horizontal, 2)
                        .shadow(radius: 1)
//                                .background(.black.opacity(0.7))

                        .clipShape(.rect(cornerRadius: 3))
                        .offset(x: -6)
                        .opacity(opacity)
                        .scaleEffect(scale)
//                                .shadow(color: .white, radius: 1)
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
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
        CardView(card: Card.all2[156], isPlayable: true)
            .overlay {
                CardAnimationView(card: Card.all2[156])
            }
    }
}
