//
//  GameNotificationPublisher.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Combine

protocol GameNotificationPublisher {
    var gameNotifPublisher: AnyPublisher<GameNotification, Never> { get }
}

class GameNotificationPublishingDelegate: GameNotificationPublisher {
    var gameNotifPublisher: AnyPublisher<GameNotification, Never> {
        gameNotifSubject.eraseToAnyPublisher()
    }

    private let gameNotifSubject = PassthroughSubject<GameNotification, Never>()
    func send(_ gameNotification: GameNotification) {
        gameNotifSubject.send(gameNotification)
    }
}
