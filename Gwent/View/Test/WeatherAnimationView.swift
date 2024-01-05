//
//  WeatherAnimationView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 02.01.2024.
//

import SwiftUI

struct WeatherAnimationView: View {
    @Namespace var first
    @Namespace var second

    @State private var cards2 = Card.inHand
    @State private var discard2: [Card] = []
    ///
    @State private var cards: [Card] = Card.inHand
    @State private var weathers: [Card] = []
    @State private var discard: [Card] = []

    private func addWeather(isBot: Bool) async {
        if isBot {
            var card = cards2[9]
            card.holderIsBot = true
            guard let handIndex = cards2.firstIndex(where: { $0.id == card.id }) else {
                return
            }

            let index = weathers.firstIndex(where: { ($0.id == card.id) || ($0.weather == card.weather) })

            if let index {
                withAnimation(.smooth(duration: 0.3)) {
                    let removed = weathers.remove(at: index)
                    if removed.holderIsBot! {
                        discard2.append(removed)
                    } else {
                        discard.append(removed)
                    }
                }
                try? await Task.sleep(for: .seconds(0.6))
            }

            withAnimation {
                cards2.remove(at: handIndex)
                weathers.append(card)
            }
        } else {
            var card = cards[9]
            card.holderIsBot = false
            guard let handIndex = cards.firstIndex(where: { $0.id == card.id }) else {
                return
            }

            let index = weathers.firstIndex(where: { ($0.id == card.id) || ($0.weather == card.weather) })

            if let index {
                withAnimation(.smooth(duration: 0.3)) {
                    let removed = weathers.remove(at: index)
                    if removed.holderIsBot! {
                        discard2.append(removed)
                    } else {
                        discard.append(removed)
                    }
                }
                try? await Task.sleep(for: .seconds(0.6))
            }

            withAnimation {
                cards.remove(at: handIndex)
                weathers.append(card)
            }
        }
    }

    var body: some View {
        HStack {
            ForEach(cards2) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: second)
            }
        }

        .border(.red)
        HStack {
            ForEach(weathers) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: card.holderIsBot! ? second : first)
            }
        }
        .frame(height: 75)
        .frame(maxWidth: .infinity)
        .border(.blue)
        DeckOfCardsView(deck: discard2, animNamespace: second, isMe: false)

        Button("To discard") {
            Task {
                withAnimation {
                    cards2.insert(Card.all2[27], at: 0)
                }
                try? await Task.sleep(for: .seconds(0.5))
                withAnimation {
                    let removed = cards2.removeFirst()
                    discard2.append(removed)
                }
            }
        }
        .buttonStyle(.borderedProminent)
        Button("Add weather ") {
            Task {
                await addWeather(isBot: false)
            }
        }

        Button("Add weather - BOT ") {
            Task {
                await addWeather(isBot: true)
            }
        }
        .buttonStyle(.borderedProminent)
        DeckOfCardsView(deck: discard, animNamespace: first, isMe: true)
        HStack {
            ForEach(cards) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: first)
            }
        }
        .border(.red)
    }
}

#Preview {
    WeatherAnimationView()
}
