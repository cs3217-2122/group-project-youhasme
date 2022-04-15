//
//  NumericUnlockCondition.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 30/3/22.
//

import Foundation

class IntegerUnlockCondition: UnlockCondition {
    enum Comparison: Int, Codable {
         case moreThan = 0
         case lessThan = 1
         case equalTo = 2
         case moreThanOrEqualTo = 3
         case lessThanOrEqualTo = 4
    }

    var statistic: GameStatistic
    var comparison: Comparison
    var unlockValue: Int

    init(statistic: GameStatistic, comparison: Comparison, unlockValue: Int) {
        self.statistic = statistic
        self.comparison = comparison
        self.unlockValue = unlockValue
    }

    func isFulfilled() -> Bool {
        switch comparison {
        case .moreThan:
            return statistic.value > unlockValue
        case .lessThan:
            return statistic.value < unlockValue
        case .equalTo:
            return statistic.value == unlockValue
        case .moreThanOrEqualTo:
            return statistic.value >= unlockValue
        case .lessThanOrEqualTo:
            return statistic.value <= unlockValue
        }
    }
}

extension IntegerUnlockCondition {
    func toPersistable() -> PersistableUnlockCondition {
        PersistableUnlockCondition(
            conditionType: .integer,
            unlockCondition: self
        )
    }

    func toPersistableIntegerUnlockCondition() -> PersistableIntegerUnlockCondition {
        PersistableIntegerUnlockCondition(
            persistableStatistic: statistic.toPersistable(),
            comparison: comparison,
            unlockValue: unlockValue)
    }
}
