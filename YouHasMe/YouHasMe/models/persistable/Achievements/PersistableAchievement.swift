//
//  PersistableAchievement.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 4/4/22.
//

import Foundation

struct PersistableAchievement: Codable {
    var name: String
    var description: String
    var persistableUnlockConditions: [PersistableUnlockCondition]
    var isUnlocked: Bool
    var isHidden: Bool
}
