//
//  MoveStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 31/3/22.
//

import Foundation

class StatisticsViewModel: Codable {
    var gameStatistics: [String: GameStatistic] = [:]

    init() {
        loadStatistics()
    }

    // jx todo: change to load from storage

    func loadStatistics() {
        let stat1 = GameStatistic(value: 0, statisticType: .level, gameEvent: .move)
        let stat2 = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: .move)
        let stat3 = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: .win)
        let stat4 = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: .designLevel)
        let stat5 = GameStatistic(value: 0, statisticType: .level, gameEvent: .move,
                                  levelId: "Abc")
        let stat6 = GameStatistic(value: 0, statisticType: .level, gameEvent: .win,
                                  levelId: "Abc")
        let stat7 = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: .designLevel)
        let stats = [stat1, stat2, stat3, stat4, stat5, stat6, stat7]
        for stat in stats {
            gameStatistics[stat.name] = stat
        }
    }

    func getStatistic(name: String) -> GameStatistic {
        guard let stat = gameStatistics[name] else {
            assert(false, "Game statistic \(name) does not exist")
        }

        return stat
    }

    func resetLevelStats() {
        for statistic in gameStatistics.values where statistic.type == .level {
            statistic.reset()
        }
    }
}
