//
//  Achievement.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 30/3/22.
//

import Foundation

class Achievement {
    var name: String
    var description: String
    var unlockConditions: [UnlockCondition]
    var isUnlocked: Bool

    init(name: String, description: String, unlockConditions: [UnlockCondition], isUnlocked: Bool = false) {
        self.name = name
        self.description = description
        self.unlockConditions = unlockConditions
        self.isUnlocked = isUnlocked
    }

    func shouldUnlock() -> Bool {
        for condition in unlockConditions where !condition.isFulfilled() {
            return false
        }

        return true
    }

    func unlockIfConditionsMet() {
        if shouldUnlock() {
            print("Unlocked")
            unlock()
        }
    }

    func unlock() {
        isUnlocked = true
    }
}

extension Achievement: Identifiable {
    var id: String {
        name
    }
}
