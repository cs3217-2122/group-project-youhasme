//
//  MoveStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 31/3/22.
//

import Foundation

class StatisticsViewModel {
    var gameStatistics: [Int: GameStatistic] = [:]

    init() {
        loadStatistics()
    }

    func loadStatistics() {
//        StatisticStorage.loadStatistics()
    }

    func getStatistic(id: Int) -> GameStatistic {
        guard let stat = gameStatistics[id] else {
            assert(false, "Game statistic \(id) does not exist")
        }

        return stat
    }

    func resetLevelStats() {
        for statistic in gameStatistics.values where statistic.type == .level {
            statistic.reset()
        }
    }
}
