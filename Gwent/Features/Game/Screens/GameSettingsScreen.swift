//
//  GameSettingsScreen.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import SwiftUI

struct GameSettingsScreen: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm
        VStack(spacing: 30) {
            Text("Options")
                .font(.custom(AppFont.Gwent.rawValue, size: 28, relativeTo: .title))

            VStack(spacing: 25) {
                Toggle(isOn: $vm.settings.isVibrationEnabled) {
                    Text("Vibrations")
                        .font(.custom(AppFont.Gwent.rawValue, size: 18, relativeTo: .body))
                }
                .tint(.brandYellow)

                Toggle(isOn: $vm.settings.isMusicEnabled) {
                    Text("Music")
                        .font(.custom(AppFont.Gwent.rawValue, size: 18, relativeTo: .body))
                }
                .tint(.brandYellow)

                Toggle(isOn: $vm.settings.isSoundsEnabled) {
                    Text("Sounds")
                        .font(.custom(AppFont.Gwent.rawValue, size: 18, relativeTo: .body))
                }
                .tint(.brandYellow)

                HStack {
                    Text("Difficulty")
                        .font(.custom(AppFont.Gwent.rawValue, size: 18, relativeTo: .body))
                    Spacer()
                    Picker("", selection: $vm.settings.difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) {
                            Text($0.description)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.brandYellow)
                    .background(.clear)
                }
            }

            HStack(spacing: 50) {
                BrandButton2(title: "Back") {
                    vm.settings.toggleScreen()
                }
                BrandButton2(title: "Customize deck") {
                    vm.settings.alert = AlertItem(
                        title: "Really?",
                        description: "Really really?",
                        cancelButton: ("No", {}),
                        confirmButton: ("Yes", {
                            vm.settings.toggleScreen()

                            vm.forfeitGame()
                        })
                    )
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.black.opacity(0.9), ignoresSafeAreaEdges: .all)
        .overlay {
            if vm.settings.alert != nil {
                AlertView(alert: $vm.settings.alert)
            }
        }
    }
}

#Preview {
    GameSettingsScreen()
        .environment(\.colorScheme, .dark)
        .environment(GameViewModel.preview)
}
