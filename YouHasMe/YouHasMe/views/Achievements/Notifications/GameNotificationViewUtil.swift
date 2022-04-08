//
//  GameNotificationViewUtil.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Foundation

struct GameNotificationViewUtil {
    static func handleRemoveGameNotification(
        viewModel: GameNotificationsViewModel, toRemove: GameNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            viewModel.hasFinishedShowing(toRemove)
        }
    }

    static func createAchievementNotification(_ achievement: Achievement) -> GameNotification {
        GameNotification(title: "Achievement Unlocked: \(achievement.name)", subtitle: achievement.description)
    }
}
