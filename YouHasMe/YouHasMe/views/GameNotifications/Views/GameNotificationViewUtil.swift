//
//  GameNotificationViewUtil.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Foundation

struct GameNotificationViewUtil {
    static func createAchievementNotification(_ achievement: Achievement) -> GameNotification {
        GameNotification(
            title: "Achievement Unlocked: \(achievement.name)",
            subtitle: achievement.description
        )
    }
}
