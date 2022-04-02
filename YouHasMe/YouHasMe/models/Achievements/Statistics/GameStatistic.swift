//
//  NumericStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 31/3/22.
//

import Foundation

class GameStatistic: Codable, Hashable {
    enum StatisticType: Int, Codable {
        case level
        case lifetime
    }

    var name: String
    var value: Int
    var type: StatisticType

    init(name: String, value: Int, statisticType: StatisticType) {
        self.name = name
        self.value = value
        self.type = statisticType
    }

    func increase() {
        value += 1
        globalLogger.info("\(name) increased to \(value)")
    }

    func reset() {
        value = 0
    }

    static func == (lhs: GameStatistic, rhs: GameStatistic) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
