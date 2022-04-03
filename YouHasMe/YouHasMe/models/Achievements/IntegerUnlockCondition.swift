//
//  NumericUnlockCondition.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 30/3/22.
//

import Foundation

class IntegerUnlockCondition: UnlockCondition {
    enum Comparison: Int, Codable {
         case MORE_THAN = 0
         case LESS_THAN = 1
         case EQUAL_TO = 2
         case MORE_THAN_OR_EQUAL_TO = 3
         case LESS_THAN_OR_EQUAL_TO = 4
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
        case .MORE_THAN:
            return statistic.value > unlockValue
        case .LESS_THAN:
            return statistic.value < unlockValue
        case .EQUAL_TO:
            return statistic.value == unlockValue
        case .MORE_THAN_OR_EQUAL_TO:
            return statistic.value >= unlockValue
        case .LESS_THAN_OR_EQUAL_TO:
            return statistic.value <= unlockValue
        }
    }
}

extension IntegerUnlockCondition {
//    func toPersistable() -> PersistableUnlockCondition {
//        PersistableUnlockCondition(
//            conditionType: .integer,
//            condition: self
//        )
//    }
}
