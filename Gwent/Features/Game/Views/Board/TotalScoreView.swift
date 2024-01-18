//
//  TotalScore.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

struct TotalScoreView: View {
    @Environment(GameViewModel.self) private var vm

    var player: Player
    var leadingPlayer: Player?
    var currentPlayer: Player?

    var isLeading: Bool {
        guard let leadingPlayer else {
            return false
        }
        return player.isBot == leadingPlayer.isBot
    }

    var isCurrent: Bool {
        guard let currentPlayer else {
            return false
        }

        return player.isBot == currentPlayer.isBot
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(player.isBot ? .Assets.scoreTotalOp : .Assets.scoreTotalMe)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)

                Text("\(player.totalScore)")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.black)
                    .shadow(color: .white, radius: 1)
                    
//                if isLeading {
//                    Image(.Assets.spikelets)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 70, height: 70)
//                        
//                }
            }
            .transition(.identity)
            .overlay {
                if isLeading {
                    Image(.Assets.spikelets)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
            }
            .shadow(color: .brandYellow, radius: isCurrent && !vm.ui.isTurnHighlightDisabled ? 15 : 0)
            if player.isPassed {
                Text("Passed")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.brandYellowSecondary)
                    .transition(.identity)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let leadingPlayer = GameViewModel.preview.player

    return HStack {
        TotalScoreView(player: GameViewModel.preview.bot, leadingPlayer: leadingPlayer)

        Spacer()

        TotalScoreView(player: GameViewModel.preview.player, leadingPlayer: leadingPlayer)
    }
    .environment(GameViewModel.preview)
}
