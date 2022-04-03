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
            if condition.isFulfilled() {
                return
            }
            if let integerCond = condition as? IntegerUnlockCondition {
                integerCond.statistic.handleGameEvent(event: gameEvent)
            }
        }
//        let statistics = unlockConditions
//            .compactMap { ($0.isFulfilled() ? nil : $0 as? IntegerUnlockCondition)?.statistic }
//        statistics.forEach { statistic in
//            statistic.handleGameEvent(event: gameEvent)
//        }
    }
}

extension Achievement: Identifiable {
    var id: String {
        name
    }
}

//
// struct PersistableAchievement: Codable {
//    var name: String
//    var description: String
//    var persistableUnlockConditions: [PersistableUnlockCondition]
//    var isUnlocked: Bool
// }
//
// extension Achievement {
//    func toPersistable() -> PersistableAchievement {
//        PersistableAchievement(name: name, description: description,
//                               persistableUnlockConditions: unlockConditions.map { $0.toPersistable() },
//                               isUnlocked: isUnlocked)
//    }
//
//    static func fromPersistable(persistable: PersistableAchievement) -> Achievement {
//        Achievement(name: persistable.name, description: persistable.description,
//                    unlockConditions: persistable
//                        .persistableUnlockConditions.map { UnlockConditionUtil.fromPersistable(persistable: $0) },
//                    isUnlocked: persistable.isUnlocked)
//    }
// }
//
// struct UnlockConditionUtil {
//    static func fromPersistable(persistable: PersistableUnlockCondition) -> UnlockCondition {
//        persistable.unlockCondition
//    }
// }
