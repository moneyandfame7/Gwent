//
//  NotificationView.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 04.01.2024.
//

import SwiftUI

// TODO: краще переробити на dictionary

struct NotificationView: View {
    let variant: Notification

    private var asset: NotificationAssets {
        NotificationAssets.all[variant]!
    }

    private var isCoin: Bool {
        variant == .coinMe || variant == .coinOp
    }

    var body: some View {
        HStack {
            Spacer().frame(width: 150)
            Text(asset.title)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
        }

        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.7))
        .foregroundStyle(.brandYellowThird)
        .overlay(alignment: .leading) {
            if isCoin {
                CoinView(asset: asset.image)
            } else {
                Image(asset.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 140)
            }
        }
        .task {
            if let sound = asset.sound {
                await SoundManager.shared.playSound(sound: sound)

                print("AFTER SOUND")
            }
        }
    }
}

#Preview {
    VStack {
        NotificationView(variant: .coinMe)
    }
}
