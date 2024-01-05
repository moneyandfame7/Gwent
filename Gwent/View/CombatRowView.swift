//
//  CombatRowView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

//                    .overlay {
//                        if let selectedDetails = viewModel.selectedCard.details, selectedDetails.combatRow == .siege {
//                            Rectangle()
//                                .fill(.brandYellow.opacity(0.3))
//                        }
////                            .border(.brandYellow, width: 3)
//                    }
struct CombatRowView: View {
    @Environment(AppState.self) private var appState
    let combatRow: CombatRow

    let isMe: Bool

    var imageName: ImageResource? {
        switch combatRow.type {
        case .close:
            return .Assets.boardRowClose
        case .ranged:
            return .Assets.boardRowRanged
        case .siege:
            return .Assets.boardRowSiege
        default: return nil
        }
    }

    private var isSelectable: Bool {
        // якщо це якась спеціальна картка там напевно можна обирати ряд у суперника, але це пізніше

        guard let selectedCard = appState.ui.selectedCard else {
            return false
        }

        let sameRow = selectedCard.combatRow == combatRow.type

        if !isMe {
            let isSpy = selectedCard.ability == .spy

            return isSpy && sameRow
        }

        let isAgileRow = selectedCard.combatRow == .agile && (combatRow
            .type == .close || combatRow.type == .ranged)

        let isDecoy = selectedCard.ability == .decoy && combatRow.cards.count > 0
        return isDecoy || sameRow || isAgileRow
    }

    /// Is special row selectable
    private var isSpecialSelectable: Bool {
        guard isMe else {
            return false
        }
        guard let selectedCard = appState.ui.selectedCard else {
            return false
        }
        let isHorn = selectedCard.type == .special && selectedCard.ability == .commanderHorn

        return isHorn && combatRow.horn == nil
    }

    var totalScoreView: some View {
        VStack {
            Text("\(combatRow.totalPower)")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .shadow(color: .white, radius: 1)
        }
        .background(
            Image(isMe ? .Assets.scoreTotalMe : .Assets.scoreTotalOp)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        )
        .frame(width: 25, height: 25)
        .position(x: 80, y: 37.5)
    }

    var highlightView: some View {
        Rectangle()
            .fill(.brandYellow.opacity(0.3))
    }

    @ViewBuilder
    var overlayView: some View {
        if combatRow.hasWeather {
            if combatRow.type == .close {
                FrostView()
            } else if combatRow.type == .ranged {
                FogView()
            } else {
                RainView()
            }
        }
        if isSelectable {
            highlightView
        }
        if let horn = combatRow.horn {
            HornOverlayView()
                .offset(y: 3)
        }
    }

    var hornView: some View {
        ZStack {
            Image(.Assets.boardRowHorn)
                .resizable()
                .scaledToFit()
                .frame(width: 50)

            if let horn = combatRow.horn {
                CardView(card: horn)
                    .matchedGeometryEffect(
                        id: horn.id,
                        in: appState.ui.namespace(isMe: isMe)
                    )
            }
        }
        .frame(width: 80)
        .frame(maxHeight: .infinity)
        .border(.gray.opacity(0.5), width: 2)
        .overlay {
            if isSpecialSelectable {
                highlightView
            }
        }
        .onTapGesture {
            guard isSpecialSelectable else {
                return
            }
            Task {
                await appState.model.playCard(
                    appState.ui.selectedCard!,
                    row: combatRow.type
                )
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            hornView
            ZStack {
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 60)
                        .opacity(0.8)
                        .zIndex(-1)
                }

                HStackOfCards(combatRow.cards, id: \.id) { card in
                    CardView(card: card, isPlayable: true, size: .extraSmall)
                        .matchedGeometryEffect(id: card.id, in: appState.ui.namespace(isMe: isMe))
                }
//                StackOfCards(
//                    cards: combatRow.cards,
//                    size: .extraSmall,
//                    isMe: isMe
//
//                )
            }
        }
        .background(Image(.Assets.texture).resizable())
        .border(.gray, width: 1)
        .overlay {
            totalScoreView
        }
        .overlay {
            overlayView
        }

        .onTapGesture {
            guard isSelectable else {
                if combatRow.cards.count > 0 {
                    print("Show card carousel.")
                }
                // if combatRow.cards.count > 0 -> appState.ui.showCarousel(combatRow.cards)
                return
            }
            Task {
                print("PLAY_CARD")
//                appState.ui.selectedCard?.details = nil

                await appState.model.playCard(
                    appState.ui.selectedCard!,
                    row: combatRow.type
                )
            }
        }
    }
}

#Preview {
    CombatRowView(
        combatRow: CombatRow(
            type: .close,
            cards: Array(Card.all2[0 ... 9])
        ),
        isMe: true
    )
    .environment(AppState.preview)
    .frame(maxHeight: 75)
}
