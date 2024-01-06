//
//  FrostView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import SwiftUI

struct FrostView: View {
    var body: some View {
        ZStack {
            Image(.Weathers.overlayFrost).resizable()
//            Image(.Weathers.frost2).resizable().opacity(0.5)
//                .zIndex(1)
//
//            Image(.Weathers.frost1)
//                .resizable()
//                .opacity(0.6)
        }
        .onAppear {
//            SoundManager.shared.playSound(sound: .frost)
        }
    }
}

#Preview {
    HStack {
        FrostView()
    }
    .frame(maxHeight: 100)
    .background(Image(.Assets.texture2))
}
