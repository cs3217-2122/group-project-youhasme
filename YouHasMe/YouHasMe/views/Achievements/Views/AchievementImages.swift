//
//  AchievementImages.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 2/4/22.
//

import Foundation

struct AchievementImages {
    static func getAchievementImageString(achievement: Achievement) -> String {
        if achievement.shouldHide {
            return "question"
        }

        switch achievement.name {
        case "Baby Steps":
            return "baby_steps"
        case "Over One Million":
            return "over_one_million"
        case "Creativity":
            return "creativity"
        case "Speedy Game":
            return "speedy_game"
        case "You are Gogo":
            return "you_are_gogo"
        default:
            return "question"
        }
    }
}

