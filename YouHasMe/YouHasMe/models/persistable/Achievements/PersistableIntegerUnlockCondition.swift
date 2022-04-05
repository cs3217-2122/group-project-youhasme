//
//  PersistableIntegerUnlockCondition.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 4/4/22.
//

import Foundation

struct PersistableIntegerUnlockCondition: Codable {
    var persistableStatistic: PersistableGameStatistic
    var comparison: IntegerUnlockCondition.Comparison
    var unlockValue: Int

    func toIntegerUnlockCondition() -> IntegerUnlockCondition {
        IntegerUnlockCondition(statistic: persistableStatistic.toGameStatistic(),
                               comparison: comparison, unlockValue: unlockValue)
    }
}
