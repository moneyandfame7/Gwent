//
//  CardDetailsView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

/// Деякі картки грають ОДРАЗУ, наприклад: leader, scorch, можливо weathers ( але в оригіналі - ні )
/// тому при натисканні буде трохи інший ефект: вона анімується і автоматично використовується
///
/// Якщо isPlayable - true і holder - bot: то це анімація картки перед її використанням. ( сховати всі кнопки )
/// Якщо isPlayable - false і  holder - bot: то це я дивлюсь картку його лідера, тому є кнопка закриття
struct CardDetailsView: View {
    @Environment(GameViewModel.self) private var vm

    @Binding var selectedCard: SelectedCard?

    private var shouldPlayInstantly: Bool {
        selectedCard?.details.type == .leader || selectedCard?.details.ability == .scorch && selectedCard?.details.type == .special
    }

    private var isCanPlay: Bool {
        if selectedCard?.holder == .bot {
            return false
        }

        if selectedCard?.details.type == .leader {
            return vm.isLeaderAvailable(player: vm.player)
        }

        return true
    }

    private func getOffsetX(geometry: GeometryProxy) -> CGFloat {
        if selectedCard!.isReadyToUse {
            return selectedCard!.holder == .me ? cardRect.width + 50 : -(cardRect.width + 50)
        }

        return 0
    }

    private var cardRect: Rect {
        if selectedCard!.isReadyToUse {
            return Rect(size: .small)
        }

        return Rect(size: .large)
    }

    private func onTap() async {
        if shouldPlayInstantly {
            await vm.playCard(selectedCard!.details)
        } else {
            withAnimation(.card) {
                selectedCard!.isReadyToUse.toggle()
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 25) {
                if isCanPlay {
                    Text("Tap to play")
                        .font(.custom("Gwent", size: 22, relativeTo: .title3))
                        .textCase(.uppercase)
                        .foregroundStyle(.white)
                        .textBorder()
                        .padding(.top, 20)
                        .opacity(selectedCard!.isReadyToUse ? 0 : 1)
                }
                Spacer()
                CardView(
                    card: selectedCard!.details,
                    isCompact: selectedCard!.isReadyToUse,
                    rect: cardRect
                )
                .overlay(alignment: .topTrailing) {
                    HStack {
                        if shouldPlayInstantly && isCanPlay {
                            IconButton(systemName: "gamecontroller.fill") {
                                print("Should Play")
                                Task {
                                    await vm.playCard(selectedCard!.details)
                                }
                            }
                            .scaleEffect(selectedCard!.isReadyToUse ? 0 : 1)
                        }
                        if selectedCard!.isPlayable && selectedCard!.holder == .me {
                            IconButton(systemName: "xmark") {
                                selectedCard = nil
                            }
                            .opacity(selectedCard!.isReadyToUse ? 0 : 1)
                        }
                    }
                    .offset(x: -10, y: 10)
                }
                .offset(x: getOffsetX(geometry: proxy))
                .shadow(color: .brandYellow, radius: 25)
                .onTapGesture {
                    if !isCanPlay {
                        return
                    }
                    Task {
                        await onTap()
                    }
                }
                Spacer()
                if !selectedCard!.isReadyToUse {
                    AbilityView(card: selectedCard!.details)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.brandYellowSecondary)
            .background(.ultraThinMaterial.opacity(selectedCard!.isReadyToUse ? 0 : 1))
        }
    }
}

#Preview {
    CardDetailsView(selectedCard: .constant(SelectedCard.bot))
        .environment(GameViewModel.preview)
        .environment(\.colorScheme, .dark)
}
