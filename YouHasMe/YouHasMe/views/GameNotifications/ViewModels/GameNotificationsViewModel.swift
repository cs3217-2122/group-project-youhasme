//
//  NotificationsViewModel.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Combine
import Foundation

class GameNotificationsViewModel: ObservableObject {
    @Published var notificationShown: GameNotification?

    @Published var gameNotificationsQueue: [GameNotification] = []

    private var subscriptions = [AnyCancellable]()

    private var isShowingNotification: Bool {
        notificationShown != nil
    }

    func addNotification(_ notif: GameNotification) {
        if isShowingNotification {
            gameNotificationsQueue.append(notif)
            return
        }

        showNotif(notification: notif)
    }

    func hasFinishedShowing(_ finishedNotif: GameNotification) {
        guard let currentShowingNotification = notificationShown else {
            return
        }

        if currentShowingNotification != finishedNotif {
            return
        }

        notificationShown = nil
        showNextNotif()
    }

    func showNotif(notification: GameNotification) {
        notificationShown = notification

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hasFinishedShowing(notification)
        }
    }

    func showNextNotif() {
        if gameNotificationsQueue.isEmpty {
            return
        }

        let nextNotif = gameNotificationsQueue.removeFirst()
        showNotif(notification: nextNotif)
    }

    func remove(_ notif: GameNotification) {
        gameNotificationsQueue = gameNotificationsQueue.filter { $0 != notif }
    }

    func setSubscriptionsFor(_ notificationPublisher: AnyPublisher<GameNotification, Never>) {
        notificationPublisher.sink { [weak self] gameNotif in
            guard let self = self else {
                return
            }

            self.addNotification(gameNotif)
        }.store(in: &subscriptions)
    }
}

extension GameNotificationsViewModel: Equatable {
    static func == (lhs: GameNotificationsViewModel, rhs: GameNotificationsViewModel) -> Bool {
        lhs.notificationShown == rhs.notificationShown && lhs.gameNotificationsQueue == rhs.gameNotificationsQueue
    }
}
