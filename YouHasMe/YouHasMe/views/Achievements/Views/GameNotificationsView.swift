//
//  GameNotificationsView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Foundation
import SwiftUI

struct GameNotificationsView: View {
    @ObservedObject var notificationsViewModel: GameNotificationsViewModel

    var body: some View {
        ZStack {
            if let gameNotif = notificationsViewModel.notificationShown {
                GameNotificationView(gameNotif: gameNotif, gameNotifsViewModel: notificationsViewModel)
            }
        }.animation(.easeInOut(duration: 1.0),
                    value: notificationsViewModel.notificationShown)
    }
}
