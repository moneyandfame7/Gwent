//
//  CircleButton.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 26.01.2024.
//

import SwiftUI

struct CircleButton: View {
    let icon: String
    var disabled: Bool
    let action: () -> Void

    init(_ icon: String, disabled: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.disabled = disabled
        self.action = action
    }

    var body: some View {
        HStack {
            Button(action: action, label: {
                Image(systemName: icon)
                    .foregroundStyle(.brandYellowSecondary.opacity(disabled ? 0.4 : 1))
                    .frame(width: 44, height: 44)

            })
            .disabled(disabled)
            .background(Image(.Assets.texture2).resizable())
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .overlay {
                Circle().stroke(.brandYellowSecondary.opacity(disabled ? 0.4 : 1), lineWidth: 2)
            }
        }
    }
}

#Preview {
    CircleButton("gearshape.fill") {
        print("alala")
    }
}
