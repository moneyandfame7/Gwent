//
//  GameResult.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 25.01.2024.
//

import SwiftUI

enum GameResult: String {
    case draw, victory, defeat

    var imageSource: String {
        return "Images/game/\(self)"
    }

    var color: Color {
        switch self {
        case .draw:
            return .gray
        case .defeat:
            return .red
        case .victory:
            return .brandYellow
        }
    }
}
