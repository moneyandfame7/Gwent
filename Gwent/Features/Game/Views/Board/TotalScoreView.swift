//
//  TotalScore.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 22.12.2023.
//

import SwiftUI

struct TotalScoreView: View {
    @Environment(GameViewModel.self) private var viewModel

    var isMe: Bool

    private var player: Player {
        viewModel.getPlayer(isBot: !isMe)
    }

    var isLeading: Bool {
        guard let leadingPlayer = viewModel.leadingPlayer else {
            return false
        }
        return player.isBot == leadingPlayer.isBot
    }

    var isCurrent: Bool {
        guard let currentPlayer = viewModel.currentPlayer else {
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
            .shadow(color: .brandYellow, radius: isCurrent ? 15 : 0)
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
    HStack {
        TotalScoreView(isMe: true)

        Spacer()

        TotalScoreView(isMe: false)
    }
    .environment(GameViewModel.preview)
}
