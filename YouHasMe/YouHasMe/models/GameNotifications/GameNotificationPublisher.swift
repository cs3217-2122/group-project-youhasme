//
//  GameNotificationPublisher.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Combine

protocol GameNotificationPublisher {
    var gameNotificationPublishingHelper: GameNotificationPublishingHelper { get }
}

extension GameNotificationPublisher {
    var gameNotifPublisher: AnyPublisher<GameNotification, Never> {
        gameNotificationPublishingHelper.gameNotifPublisher
    }

    func sendGameNotification(_ gameNotification: GameNotification) {
        gameNotificationPublishingHelper.send(gameNotification)
    }
}
