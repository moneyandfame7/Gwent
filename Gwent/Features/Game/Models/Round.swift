//
//  Round.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 23.12.2023.
//

import Foundation

struct Round: Identifiable {
    let id = UUID()
    
    let winner: Player?
    let scoreMe: Int
    let scoreAI: Int
}


