//
//  NumericUnlockCondition.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 30/3/22.
//

import Foundation

class NumericUnlockCondition: UnlockCondition {
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

    init(statistics: StatisticsViewModel, statisticName: String, comparison: Comparison, unlockValue: Int) {
        self.statistic = statistics.getStatistic(name: statisticName)
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
