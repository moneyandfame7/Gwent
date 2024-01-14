//
//  CardFlipAnimationView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 10.01.2024.
//

import SwiftUI

class CardTest: Identifiable, ObservableObject {
    let id = UUID()
    let frontImageName: String
    let backImageName: String
    @Published var isFlipped: Bool = true

    init(frontImageName: String, backImageName: String) {
        self.frontImageName = frontImageName
        self.backImageName = backImageName
    }
}

struct CardTestView: View {
    @ObservedObject var card: CardTest

    @State private var offset: CGFloat = 0

    @State private var scale: CGFloat = 1

    var body: some View {
        Image(card.isFlipped ? card.backImageName : card.frontImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)

            .rotation3DEffect(
                .degrees(card.isFlipped ? 180 : 0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .offset(x: offset)
            .scaleEffect(scale)
            .onTapGesture {
                Task {
                    withAnimation {
                        offset = 50

//                        card.isFlipped.toggle()
                    }

                    try? await Task.sleep(for: .seconds(0.2))

                    withAnimation(.easeInOut(duration: 0.5)) {
                        card.isFlipped.toggle()
                    }

//                    try? await Task.sleep(for: .seconds(1))

                    withAnimation(.easeInOut(duration: 0.6)) {
                        scale = 2
                    }

                    try? await Task.sleep(for: .seconds(2))

                    withAnimation(.easeInOut(duration: 0.6)) {
                        offset = -100
                        scale = 0.5
                    }
//                    try? await Task.sleep(for: .seconds(0.3))

//                    try? await Task.sleep(for: .seconds(0.5))
                }
//                withAnimation(.easeInOut(duration: 1)) {
//                    card.isFlipped.toggle()
//                }
            }
    }
}

struct CardFlipAnimationView: View {
    @StateObject var card1 = CardTest(
        frontImageName: "Assets/deck_back_scoiatael",
        backImageName: "Assets/deck_back_monsters"
    )
    // Add more card objects here

    @Namespace var animation

    @State private var isFlag = false

    @State private var array: [UUID] = [
        UUID(),
        UUID(),
        UUID(),
        UUID(),
    ]

    @State private var array2: [UUID] = [
        UUID(),
        UUID(),
    ]

    @State private var offset: CGFloat = 0

    @State private var scale: CGFloat = 1

    @State private var isFlipped = false

    @Namespace var animation2
    var body: some View {
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            VStack {
                Button("Click") {
                    
                }
                .buttonStyle(.borderedProminent)
                HStack {
                    HStack(spacing: 0) {
                        ForEach(array, id: \.self) { id in
                            Image("Assets/deck_back_scoiatael")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .matchedGeometryEffect(
                                    id: id,
                                    in: animation
                                )
                        }
                    }

                    ZStack {
                        ForEach(array2, id: \.self) {id in
                            Image("Assets/deck_back_scoiatael")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .rotation3DEffect(
                                    .degrees(isFlipped ? 180 : 0),
                                    axis: (x: 0.0, y: 1.0, z: 0.0)
                                )
                                .offset(x: offset)
                                .scaleEffect(scale)
                            
                                .matchedGeometryEffect(
                                    id: id,
                                    in: animation2
                                )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CardFlipAnimationView()
}
