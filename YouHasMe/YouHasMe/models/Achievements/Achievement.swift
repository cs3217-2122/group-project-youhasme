//
//  Achievement.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 30/3/22.
//

import Foundation

class Achievement: Identifiable {
    var id = UUID()
    var name: String
    var unlockConditions: [UnlockCondition]
    var isUnlocked: Bool

    init(name: String, unlockConditions: [UnlockCondition], isUnlocked: Bool = false) {
        self.name = name
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
