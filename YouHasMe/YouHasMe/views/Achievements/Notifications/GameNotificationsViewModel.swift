//
//  NotificationsViewModel.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Combine
import Foundation

class GameNotificationsViewModel: ObservableObject {
    @Published var notificationShown: GameNotification? = GameNotification(title: "test", subtitle: "Test")

    @Published var gameNotificationsQueue: [GameNotification] =
    [GameNotification(title: "notif 2", subtitle: "")]

    func addNotification(_ notif: GameNotification) {
        if notificationShown != nil {
            gameNotificationsQueue.append(notif)
            return
        }

        notificationShown = notif
    }

    func hasFinishedShowing(_ notif: GameNotification) {
        if notificationShown != nil && notificationShown! == notif {
            notificationShown = nil
        } else {
            return
        }

        if gameNotificationsQueue.isEmpty {
            return
        }

        let nextNotif = gameNotificationsQueue.removeFirst()
        notificationShown = nextNotif
        // for some reason onAppear is only called once
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hasFinishedShowing(nextNotif)
        }
    }

    func remove(_ notif: GameNotification) {
        gameNotificationsQueue = gameNotificationsQueue.filter { $0 != notif }
    }
}

extension GameNotificationsViewModel: Equatable {
    static func == (lhs: GameNotificationsViewModel, rhs: GameNotificationsViewModel) -> Bool {
        lhs.notificationShown == rhs.notificationShown && lhs.gameNotificationsQueue == rhs.gameNotificationsQueue
    }
}
