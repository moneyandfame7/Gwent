//
//  RainView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import AVKit
import SwiftUI

struct RainView: View {
    var body: some View {
        ZStack {
            Image(.Weathers.overlayRain).resizable()
//            Image(.Weathers.rain).resizable()
//            Image(.Weathers.rain2).resizable()
//            Image(.Weathers.rain3).resizable()
            ////            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }

        .onAppear {
            SoundManager.shared.playSound(sound: .rain2)
        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 200)
//        .background(Image(.texture).resizable())

//            .controlGroupStyle(.)
    }
}

#Preview {
    RainView()
}
