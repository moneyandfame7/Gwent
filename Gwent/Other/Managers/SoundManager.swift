//
//  SoundManager.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import AVFoundation
import SwiftUI

class SoundManager: NSObject {
    private var players: [SoundManager.SoundName: AVAudioPlayer] = [:]

    private var completions: [AVAudioPlayer: () -> Void] = [:]

    func playSound(sound: SoundManager.SoundName)  {
        guard let file = NSDataAsset(name: sound.assetName) else {
            print("😡 Sound \(sound.rawValue) not found in assets!")
            return
        }
        do {
            guard let player = players[sound] else {
                players[sound] = try AVAudioPlayer(data: file.data)
                guard let newPlayer = players[sound] else {
                    return
                }

                Task(priority: .background) {
                    newPlayer.play()
                }

//                try? await Task.sleep(for: .seconds(newPlayer.duration))
                return
            }

            Task(priority: .background) {
                player.play()
            }

//            try? await Task.sleep(for: .seconds(player.duration))

        } catch {
            print("😡 ERROR: \(error.localizedDescription)")
        }
    }
}

extension SoundManager {
    static let shared = SoundManager()
    static let isEnabled = true

    enum SoundName: String, CaseIterable {
        /// Overlays
        case frost, fog, rain, horn
        case clearWeather = "clear_weather"

        /// Round Notifications
        case coin
        case turnMe = "turn_me"
        case turnOp = "turn_op"
        case roundStarted = "round_started"
        case roundWin = "round_win"
        case roundLose = "round_lose"

        /// Common
        case deck
        case drawCard = "draw_card"

        /// Cards
        case hero, close, ranged, siege, medic, scorch, spy
        case tightBond = "tight_bond"

        var assetName: String {
            switch self {
            case .frost, .fog, .rain, .horn, .clearWeather:
                return "Sounds/overlays/\(rawValue)"

            case .coin, .turnMe, .turnOp, .roundStarted, .roundWin, .roundLose:
                return "Sounds/notifications/\(rawValue)"

            case .deck, .drawCard:
                return "Sounds/common/\(rawValue)"

            case .hero, .close, .ranged, .siege, .medic, .scorch, .spy, .tightBond:
                return "Sounds/cards/\(rawValue)"
            }
        }
    }
}
