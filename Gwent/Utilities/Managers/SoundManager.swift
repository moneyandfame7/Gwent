//
//  SoundManager.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 21.12.2023.
//

import AVFoundation
import SwiftUI

class SoundManager {
    private var player: AVAudioPlayer?

    private var players: [SoundManager.SoundName2: AVAudioPlayer?] = [:]

    func playSound(sound: SoundManager.SoundName) {
        guard let file = NSDataAsset(name: "Sounds/\(sound.rawValue)") else {
            print("😡 Sound \(sound.rawValue) not found in assets!")
            return
        }
        do {
//            players[sound]
            player = try AVAudioPlayer(data: file.data)
            player?.play()
        } catch {
            print("😡 ERROR: \(error.localizedDescription)")
        }
    }

    func playSound2(sound: SoundManager.SoundName2) {
        guard let file = NSDataAsset(name: sound.assetName2) else {
            print("😡 Sound \(sound.rawValue) not found in assets!")
            return
        }
        do {
            guard let player = players[sound] else {
                players[sound] = try AVAudioPlayer(data: file.data)
                players[sound]??.play()

                return
            }

            player?.play()

//            player = try AVAudioPlayer(data: file.data)
//            player?.play()
        } catch {
            print("😡 ERROR: \(error.localizedDescription)")
        }
    }
}

extension SoundManager {
    static let shared = SoundManager()
    static let isEnabled = true

    enum SoundName: String, CaseIterable {
        case clearWeather, frost, fog, rain1, rain2
    }

    enum SoundName2: String, CaseIterable {
        /// Overlays
        case frost, fog, rain, horn

        /// Round Notifications
        case coin
        case turnMe = "turn_me"
        case turnOp = "turn_op"
        case roundStarted = "round_started"
        case roundWin = "round_win"
        case roundLose = "round_lose"

        /// Card Placing
        /// temp solution: треба через swift self
        var assetName: String {
            "Sounds/overlays/\(rawValue)"
        }

        /// Common
        case deck

        /// Cards

        case hero, close, ranged, siege, medic, scorch, spy

        var assetName2: String {
            switch self {
            case .frost, .fog, .rain, .horn:
                return "Sounds/overlays/\(rawValue)"

            case .coin, .turnMe, .turnOp, .roundStarted, .roundWin, .roundLose:
                return "Sounds/notifications/\(rawValue)"

            case .deck:
                return "Sounds/common/\(rawValue)"

            case .hero, .close, .ranged, .siege, .medic, .scorch, .spy:
                return "Sounds/cards/\(rawValue)"
            }
        }
    }
}
