//
//  NumericStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 31/3/22.
//

import Foundation

class GameStatistic: Hashable {
    enum StatisticType: Int, Codable {
        case level
        case lifetime
    }

    var value: Int
    var type: StatisticType
    var gameEvent: AbstractGameEvent

    init(value: Int, statisticType: StatisticType, gameEvent: AbstractGameEvent) {
        self.value = value
        self.type = statisticType
        self.gameEvent = gameEvent
    }

    func increase() {
        value += 1
        // globalLogger.info("increased to \(value)")
    }

    func reset() {
        value = 0
    }

    static func == (lhs: GameStatistic, rhs: GameStatistic) -> Bool {
        lhs === rhs
    }

    func handleGameEvent(event: AbstractGameEvent) {
        if gameEvent.type == .win {
//            print(event.type)
        }

        if !event.containsGameEvent(otherGameEvent: self.gameEvent) {
            return
        }
        increase()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension GameStatistic {
    func toPersistable() -> PersistableGameStatistic {
        PersistableGameStatistic(value: value, statisticType: type, persistableGameEvent: gameEvent.toPersistable())
    }
}
