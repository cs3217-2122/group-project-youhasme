//
//  AchievementImages.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 2/4/22.
//

import Foundation

struct AchievementImages {
    static func getAchievementImageString(achievement: Achievement) -> String {
        switch achievement.name {
        case "Baby Steps":
            return "baba"
        default:
            return "question"
        }
    }
}

