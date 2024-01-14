//
//  FactionAbilities.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 09.01.2024.
//

import Foundation

final class FactionAbilities {
    private let game: GameViewModel
    
    init(game: GameViewModel) {
        self.game = game
    }
    // Northern
    /// коли виграв раунд, витягує додаткову картку
    func northern(player: Player) {
        game.eventManager.attach(for: .roundStart) {
//            if game.roundCount > 1 && game.roundHistory.last.winner == player
            
            return nil
        }
    }
    

    // Nilfgaard ( немає обробки ніякої )
    /// якщо нічия, то виграє в раунді
    
    // Scoiatael
    /// вирішує хто ходить, але якщо і там і там scoiatael - монетка
    func scoiatael(player: Player) {
        game.eventManager.attach(for: .gameStart) {
            let op = self.game.getOpponent(for: player)
            
            if op.deck.faction == .scoiatael && player.deck.faction == .scoiatael {
                
            }else if player.isBot {
                self.game.firstPlayer = Int.random(in: 0...1) == 0 ? self.game.bot : self.game.player
                
                
            } else  {
              // обираємо хто перший ходить
    //            game.ui.showPopup()
            }
            
            // Тут має бути логіка повʼязана з порпереднім кодом
            return true
        }
        
    }

    // Monsters
    /// залишає одну рандомну картку на полі бою
}
