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
            globalLogger.info("Achievement [\(name)] Unlocked")
            unlock()
        }
    }

    func unlock() {
        isUnlocked = true
    }

    func updateStatistics(gameEvent: AbstractGameEvent) {
        unlockConditions.forEach { condition in
            if let integerCond = condition as? IntegerUnlockCondition {
                let stat = integerCond.statistic
                stat.handleGameEvent(event: gameEvent)
            }
        }
    }

    func getLevelStatistics() -> [GameStatistic] {
        unlockConditions.compactMap { condition in
            if let integerCond = condition as? IntegerUnlockCondition {
                let stat = integerCond.statistic
                if stat.type == .level {
                    return stat
                }
            }
            return nil

        }
    }
}

extension Achievement: Identifiable {
    var id: String {
        name
    }
}

 extension Achievement {
    func toPersistable() -> PersistableAchievement {
        PersistableAchievement(name: name, description: description,
                               persistableUnlockConditions: unlockConditions.map { $0.toPersistable() },
                               isUnlocked: isUnlocked)
    }

    static func fromPersistable(persistable: PersistableAchievement) -> Achievement {
        Achievement(name: persistable.name, description: persistable.description,
                    unlockConditions: persistable
                        .persistableUnlockConditions.map { UnlockConditionUtil.fromPersistable(persistable: $0) },
                    isUnlocked: persistable.isUnlocked)
    }
 }
