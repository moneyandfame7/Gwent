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
        VStack {
            Text("Game Settings Screen")
                .font(.title)
            Button("Close") {
                vm.settings.toggleScreen()
            }
            Button("Alert") {
//                vm.ui.showAlert(
//                    AlertItem(
//                        title: "Title",
//                        description: "Description",
//                        cancelButton: (title: "Hui", action: { print("Ladno") }),
//                        confirmButton: (title: "Hui2", action: { print(" Ladno") })
//
                ////                        confirmButton: ("Confirm", { print("") })
                ////                        cancelButton: (title: "Cancel", action: { print("Cancel") }),
                ////                        confirmButton: (title: " Confirm", action: { print("Confirm") })
//                    )
//                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.9))
        .ignoresSafeArea()
    }
}

#Preview {
    GameSettingsScreen()
        .environment(\.colorScheme, .dark)
        .environment(GameViewModel.preview)
}
