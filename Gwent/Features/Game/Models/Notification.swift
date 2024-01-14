//
//  Notification.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 06.01.2024.
//

import SwiftUI

enum Notification: String {
    /// Coin flip animation
    case coinMe, coinOp

    case turnMe, turnOp

    /// Faction ability
    case monsters, northern, scoiatael, nilfgaard

    /// Round result
    case roundStarted, roundDraw, roundPassedMe, roundPassedOp, roundWin, roundLose
}

struct NotificationAssets {
    let image: ImageResource
    let title: String
    var sound: SoundManager.SoundName?
}
extension NotificationAssets {
    static let all: [Notification: NotificationAssets] = [
        .coinMe: NotificationAssets(
            image: .Images.Notifications.coinMe,
            title: "You will go first",
            sound: .coin
        ),
        .coinOp: NotificationAssets(
            image: .Images.Notifications.coinOp,
            title: "Your opponent will go first",
            sound: .coin
        ),
        .turnMe: NotificationAssets(
            image: .Images.Notifications.turnMe,
            title: "Your turn!",
            sound: .turnMe
        ),
        .turnOp: NotificationAssets(
            image: .Images.Notifications.turnOp,
            title: "Opponent's turn",
            sound: .turnOp
        ),
        .monsters: NotificationAssets(
            image: .Images.Notifications.monsters,
            title: "Monsters faction ability triggered - one randomly-chosen Monster Unit Card stays on the board"
        ),
        .northern: NotificationAssets(
            image: .Images.Notifications.northern,
            title: "Northern Realms faction ability triggered - North draws an additional card."
        ),
        .scoiatael: NotificationAssets(
            image: .Images.Notifications.scoiatael,
            title: "Opponent used the Scoia'tael faction perk to go first."
        ),
        .nilfgaard: NotificationAssets(
            image: .Images.Notifications.nilfgaard,
            title: "Nilfgaard faction ability triggered - Nilfgaard wins the tie."
        ),
        .roundDraw: NotificationAssets(
            image: .Images.Notifications.roundDraw,
            title: "The round ended in a draw"
        ),
        .roundStarted: NotificationAssets(
            image: .Images.Notifications.roundStarted,
            title: "Round Start",
            sound: .roundStarted
        ),
        .roundPassedMe: NotificationAssets(
            image: .Images.Notifications.roundPassed,
            title: "Round passed"
        ),
        .roundPassedOp: NotificationAssets(
            image: .Images.Notifications.roundPassed,
            title: "Your opponent has passed"
        ),
        .roundLose: NotificationAssets(
            image: .Images.Notifications.roundLose,
            title: "Your opponent won the round",
            sound: .roundLose
        ),
        .roundWin: NotificationAssets(
            image: .Images.Notifications.roundWin,
            title: "You won the round!",
            sound: .roundWin
        ),
    ]

}


