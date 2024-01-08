//
//  CardView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 20.12.2023.
//

import SwiftUI

struct CustomShape: Shape {
    let height: CGFloat

    var rectToRemove: CGFloat {
        height / 3.875
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rectToRemove))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - rectToRemove))
        path.closeSubpath()
        return path
    }
}

struct Rect {
    var height: CGFloat
    var width: CGFloat {
        height / aspectRatio
    }

    var radius: CGFloat

    // хз неправильно напевно але впадлу перероблювати
    private let aspectRatio: CGFloat = 1.94666666667
    private let partOfPower = 3.3
    let powerOffset: CGFloat
    let powerHeight: CGFloat

    init(size: Size) {
        switch size {
        case .extraSmall:
            height = 85
            radius = 5
            powerOffset = -1
        case .small:
            height = 200
            radius = 10
            powerOffset = -2
        case .medium:
            height = 350
            radius = 18
            powerOffset = -5
        case .large:
            height = 500
            radius = 25
            powerOffset = -8
        }
        powerHeight = height / partOfPower
//        self.width = self.height / aspectRatio
    }

    init(height: CGFloat, radius: CGFloat = 0) {
        self.height = height
        self.radius = radius
        if height <= 100 {
            powerOffset = -1
        } else if height <= 200 {
            powerOffset = -2
        } else {
            powerOffset = -5
        }
        powerHeight = self.height / partOfPower
    }

    enum Size {
        case extraSmall, small, medium, large
    }
}

struct CardView: View {
    let card: Card
    var isCompact: Bool
    var rect: Rect
    var isPlayable: Bool
    // TODO: animations if abilityActivated
    /// Яку частину картки займає тільки опис ( нижня частина картки )
    private let partOfDescriptionSize = 3.875

    init(card: Card, isCompact: Bool = true, isPlayable: Bool = false, size: Rect.Size = .extraSmall) {
        self.card = card
        self.isCompact = isCompact
        rect = Rect(size: size)
        self.isPlayable = isPlayable
    }

    init(card: Card, isCompact: Bool = true, isPlayable: Bool = false, rect: Rect) {
        self.card = card
        self.isCompact = isCompact
        self.rect = rect
        self.isPlayable = isPlayable
    }

    @State private var animation = true
    var body: some View {
//        HStack {
//            GeometryReader { geometry in

        VStack {
            Image("Cards/\(card.image)")
                .resizable()
                .scaledToFit()
                .frame(height: rect.height)
                .overlay(alignment: .topLeading) {
                    if let power = card.power, let editedPower = card.editedPower {
                        CardPowerOverlay(power: power, editedPower: editedPower, rect: rect)
                    }
                }

//                .clipShape(CustomShape(height: isCompact ? height : 0))
        }
        .frame(
            height: isCompact ? rect.height - (rect.height / partOfDescriptionSize) : rect.height,
            alignment: .top
        )
        .clipShape(.rect(cornerRadius: rect.radius))
        .overlay {
            if (isPlayable && card.ability != .tightBond) || card.shouldAnimate || card.animateAs != nil {
                CardAnimationView(card: card)
            }
        }
        .onChange(of: card.animateAs) {
            print("CHANGED #\(card.id)", card.animateAs)
        }
        .task {
            guard isPlayable else {
                return
            }

            Task(priority: .background) {
                if card.type == .hero {
                    SoundManager.shared.playSound2(sound: .hero)
                } else if card.combatRow == .close {
                    SoundManager.shared.playSound2(sound: .close)
                } else if card.combatRow == .ranged {
                    SoundManager.shared.playSound2(sound: .ranged)
                } else if card.combatRow == .siege {
                    SoundManager.shared.playSound2(sound: .siege)
                }
            }
            try? await Task.sleep(for: .seconds(1.2))

            withAnimation(.smooth(duration: 1.5)) {
                animation = false
            }
        }
//        .shadow(radius: 3, y: 5)
//        .scaleEffect(isCompact ? 0.8 : 1)
//        }
    }
}

private struct CardPowerOverlay: View {
    let power: Int
    let editedPower: Int
    let rect: Rect

    private var textColor: Color {
        if editedPower > power {
            return .green
        } else if editedPower < power {
            return .red
        }

        return .black
    }

    var body: some View {
        /// Hero:
        /// todo: прибрати ці множення ?? ( з ними все працює кайфово на всіх розмірах )
        /// я забув, що в hero ніяк не змінюється power
//        if type == .hero {
//            Image(.Assets.powerHero)
//                .resizable()
//                .scaledToFit()
//                .frame(height: rect.powerHeight)
//                .offset(x: rect.powerOffset, y: rect.powerOffset)
//                .overlay(alignment: .topLeading) {
//                    VStack {
//                        Text("\(15)")
//                            .foregroundStyle(textColor)
//                            .font(.system(size: 7))
//                            .fontWeight(.semibold)
//                    }
//                    .frame(width: rect.powerHeight / 2.3)
//                    //                            .border(.red)
//                    .offset(x: rect.powerHeight * 0.07, y: rect.powerHeight * 0.12)
//                    .foregroundStyle(.white)
//                }
//            /// Normal:
//        } else {
        Image(.Assets.powerNormal)
            .resizable()
            .scaledToFit()
            .frame(width: 25)
            .offset(x: -1.5, y: -1.5)
            .overlay(alignment: .topLeading) {
                VStack {
                    Text("\(editedPower)")
                        .font(.system(size: 7))
                        .fontWeight(.semibold)
                        .foregroundStyle(textColor)
                }

                .frame(width: 25 / 1.9)

                .offset(y: 2)
            }
    }
}

#Preview {
    VStack {
        CardView(card: .all2[47], isCompact: true, size: .extraSmall)
//            .scaleEffect(5)
    }
    .frame(maxWidth: .infinity, maxHeight: 500)
    .background(.red)
}
