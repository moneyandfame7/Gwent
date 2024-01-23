//
//  RowView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

struct RowView: View {
    @Environment(GameViewModel.self) private var vm
    @Binding var row: Row

    let isMe: Bool

    var imageName: ImageResource? {
        switch row.type {
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
        guard let selectedCardDetails = vm.ui.selectedCard?.details else {
            return false
        }
        if vm.ui.selectedCard?.holder == .bot {
            return false
        }

        if selectedCardDetails.ability == .decoy {
            return false
        }

        let sameRow = selectedCardDetails.combatRow == row.type
        let isSpy = selectedCardDetails.ability == .spy

        if !isMe {
            return isSpy && sameRow
        }

        let isAgileRow = selectedCardDetails.combatRow == .agile && (row
            .type == .close || row.type == .ranged)

        let isDecoy = selectedCardDetails.ability == .decoy && row.cards.count > 0
        return !isSpy && (isDecoy || sameRow || isAgileRow)
    }

    /// Is special row selectable
    private var isSpecialSelectable: Bool {
        guard isMe else {
            return false
        }
        guard let selectedCardDetails = vm.ui.selectedCard?.details else {
            return false
        }

        return selectedCardDetails.isHorn && row.horn == nil
    }

    /// Чи можна тапнути по кардці? тапаємо по екранчіку..
    private func isCardSelectable(_ card: Card) -> Bool {
        guard isMe else {
            return false
        }
        guard let selectedCardDetails = vm.ui.selectedCard?.details else {
            return false
        }

        return card.type == .unit && selectedCardDetails.ability == .decoy
    }

    private func onTapRow() async {
        if vm.ui.isDisabled {
            return
        }
        guard isSelectable else {
            if row.cards.isEmpty {
                return
            }
            let carousel = Carousel(
                cards: row.cards,
                title: "Cards in \(row.type) row",
                cancelButton: "Hide"
            )

            return vm.ui.showCarousel(carousel)
        }

        await vm.playCard(
            vm.ui.selectedCard!.details,
            rowType: row.type
        )
    }

    private func onTapCard(_ card: Card, selectable: Bool) async {
        if vm.ui.isDisabled {
            return
        }

        if !selectable {
            return await onTapRow()
        }

        await vm.playDecoy(
            vm.ui.selectedCard!.details,
            target: card,
            rowType: row.type
        )
    }

    private func onTapSpecial() async {
        if vm.ui.isDisabled {
            return
        }

        guard isSpecialSelectable else {
            return
        }

        await vm.playCard(
            vm.ui.selectedCard!.details,
            rowType: row.type
        )
    }

    @ViewBuilder
    private func cardItemView(_ card: Card) -> some View {
        let selectable = isCardSelectable(card)

        CardView(card: card, isPlayable: true, size: .extraSmall)
            .matchedGeometryEffect(id: card.id, in: vm.ui.namespace(isMe: isMe))
            .overlay(highlightView(selectable))
            .onTapGesture {
                Task {
                    await onTapCard(card, selectable: selectable)
                }
            }
    }

    private var totalScoreView: some View {
        VStack {
            Text("\(row.totalPower)")
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
    }

    @ViewBuilder
    private func highlightView(_ highlight: Bool) -> some View {
        if highlight {
            Rectangle()
                .fill(.brandYellow.opacity(0.3))
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        Group {
            if row.hasWeather {
                if row.type == .close {
                    FrostView()
                } else if row.type == .ranged {
                    FogView()
                } else {
                    RainView()
                }
            }

            highlightView(isSelectable)

            let showHornOverlay = row.cards.contains(where: { $0.ability == .commanderHorn }) || row.horn != nil

            if showHornOverlay {
                HornOverlayView()
                    .offset(y: 3)
            }
        }
        // Важливо, щоб можна було обрати картку, коли є якийсь overlay.
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var hornView: some View {
        ZStack {
            Image(.Assets.boardRowHorn)
                .resizable()
                .scaledToFit()
                .frame(width: 50)

            if let horn = row.horn {
                CardView(card: horn)
                    .matchedGeometryEffect(
                        id: horn.id,
                        in: vm.ui.namespace(isMe: isMe)
                    )
            }
            totalScoreView
                .zIndex(1)
                .offset(x: 42)
        }
        .frame(width: 80)
        .frame(maxHeight: .infinity)
        .overlay(highlightView(isSpecialSelectable))
        .onTapGesture {
            Task {
                await onTapSpecial()
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            hornView
                .zIndex(2)
            ZStack {
                if let imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 60)
                        .opacity(0.8)
                        .zIndex(-1)
                }

                HStackOfCards(row.cards, id: \.id) { card in
                    cardItemView(card)
                }
            }
        }
        .background(Image(.Assets.texture).resizable())
        .border(.brandBrown, width: 1)
        .overlay(overlayView)
        .onTapGesture {
            Task {
                await onTapRow()
            }
        }
        .onChange(of: row.hornEffects) { _, _ in
            row.calculateCardsPower()
        }
        .onChange(of: row.moraleBoost) { _, _ in
            row.calculateCardsPower()
        }
    }
}

#Preview("Default") {
    RowView(
        row: .constant(Row(
            type: .close,
            cards: Array(Card.all2[0 ... 9])
        )),
        isMe: true
    )
    .environment(GameViewModel.preview)
    .frame(maxHeight: 75)
}

#Preview("With overlay") {
    RowView(
        row: .constant(
            Row(
                type: .close,
                cards: [Card.all2[5]],
                hasWeather: true
            )
        ), isMe: true
    )
    .environment(GameViewModel.preview)
    .frame(maxHeight: 75)
}
