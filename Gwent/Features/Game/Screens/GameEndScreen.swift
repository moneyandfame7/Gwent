//
//  GameEndScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import SwiftUI

struct GameEndScreen: View {
    @Environment(AppState.self) private var appState

    @Environment(GameViewModel.self) private var vm

    private var result: GameResult {
        
        
        guard let lastRound = vm.roundHistory.last else {
            return .defeat
        }

        guard let winner = lastRound.winner else {
            return .draw
        }

        return winner.isBot ? .defeat : .victory
    }

    @ViewBuilder
    private var tableView: some View {
        VStack(spacing: 25) {
            HStack(spacing: 0) {
                Text("")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Round 1")
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Round 2")
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Round 3")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .font(.custom(AppFont.PTSans.rawValue, size: 15, relativeTo: .subheadline))
            .foregroundStyle(.gray)
            .multilineTextAlignment(.center)

            HStack(spacing: 0) {
                Text("You")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                    .font(.custom(AppFont.PTSans.rawValue, size: 17, relativeTo: .body))
                    .foregroundStyle(.brandYellow)

                ForEach(vm.roundHistory) { round in
                    Text("\(round.scoreMe)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.custom(AppFont.PTSans.rawValue, size: 20, relativeTo: .title3))
                        .foregroundStyle(round.winner != nil ? round.winner!.isBot ? .white : .brandYellow : .white)
                }
            }

            HStack(spacing: 0) {
                Text("Opponent")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20)
                    .font(.custom(AppFont.PTSans.rawValue, size: 17, relativeTo: .body))
                    .foregroundStyle(.brandYellow)
                    .multilineTextAlignment(.trailing)

                ForEach(vm.roundHistory) { round in
                    Text("\(round.scoreAI)")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.custom(AppFont.PTSans.rawValue, size: 20, relativeTo: .title3))
                        .foregroundStyle(round.winner != nil ? round.winner!.isBot ? .brandYellow : .white : .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
    }

    var body: some View {
        VStack {
            Image(result.imageSource)
                .resizable()
                .scaledToFit()
                .shadow(color: result.color, radius: 60, y: -20)
            Spacer().frame(height: 70)

            tableView
            Spacer().frame(height: 100)

            HStack {
                BrandButton2(title: "Close") {
                    appState.navigate(to: .deck)
                }

                BrandButton2(title: "Restart") {
                    Task {
                        vm.restartGame()
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical)
        .background(.black.opacity(0.9), ignoresSafeAreaEdges: .all)
    }
}

#Preview {
    GameEndScreen()
        .environment(AppState.preview)
        .environment(GameViewModel.preview)
}
