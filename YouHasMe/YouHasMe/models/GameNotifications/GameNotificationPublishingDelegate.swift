//
//  GameNotificationPublishingDelegate.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Combine

class GameNotificationPublishingDelegate {
    var gameNotifPublisher: AnyPublisher<GameNotification, Never> {
        gameNotifSubject.eraseToAnyPublisher()
    }

    private let gameNotifSubject = PassthroughSubject<GameNotification, Never>()
    func send(_ gameNotification: GameNotification) {
        gameNotifSubject.send(gameNotification)
    }
}
