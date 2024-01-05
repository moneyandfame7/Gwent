//
//  FogView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import SwiftUI

struct FogView: View {
    var body: some View {
        ZStack {
            Image(.Weathers.overlayFog).resizable()

        }
        .onAppear {
            SoundManager.shared.playSound(sound: .fog)
        }
    }
}

#Preview {
    HStack {
        FogView()
    }
    .frame(maxHeight: 100)
    .background(.white)
}
