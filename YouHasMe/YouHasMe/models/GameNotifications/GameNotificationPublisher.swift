//
//  GameNotificationPublisher.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Combine

protocol GameNotificationPublisher {
    var gameNotificationPublishingDelegate: GameNotificationPublishingDelegate { get }
}

extension GameNotificationPublisher {
    var gameNotifPublisher: AnyPublisher<GameNotification, Never> {
        gameNotificationPublishingDelegate.gameNotifPublisher
    }

    func sendGameNotification(_ gameNotification: GameNotification) {
        gameNotificationPublishingDelegate.send(gameNotification)
    }
}
