//
//  PersistableGameStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 4/4/22.
//

import Foundation

public struct PersistableGameStatistic: Codable {
    var value: Int
    var statisticType: GameStatistic.StatisticType
    var persistableGameEvent: PersistableAbstractGameEvent

    func toGameStatistic() -> GameStatistic {
        GameStatistic(value: value, statisticType: statisticType, gameEvent: persistableGameEvent.toAbstractGameEvent())
    }
}
