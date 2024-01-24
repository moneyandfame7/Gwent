//
//  AIStrategy.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.01.2024.
//

import Foundation

protocol AIStrategy {
    var game: GameViewModel { get }
    
    func startTurn() async

    func initialRedraw()

    func medic(cards: [Card]) -> Card?
}
