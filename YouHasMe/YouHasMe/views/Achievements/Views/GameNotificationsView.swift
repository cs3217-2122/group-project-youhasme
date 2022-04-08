//
//  GameNotificationsView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Foundation
import SwiftUI

struct GameNotificationsView: View {
    @ObservedObject var gameNotificationsViewModel: GameNotificationsViewModel

    var body: some View {
        ZStack {
            if let gameNotif = gameNotificationsViewModel.notificationShown {
                GameNotificationView(gameNotif: gameNotif, gameNotifsViewModel: gameNotificationsViewModel)
            }
        }.animation(.easeInOut(duration: 1.0),
                    value: gameNotificationsViewModel.notificationShown)
    }
}
