//
//  MoveStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 31/3/22.
//

import Foundation

class Statistics: Codable {
    var gameStatistics: [String: GameStatistic] = [:]

    init() {
        loadStatistics()
    }

    private func addLevelMove() {
        getStatistic(name: "Level Moves").increase()
    }

    private func addLifetimeMove() {
        getStatistic(name: "Lifetime Moves").increase()
    }

    func addMove() {
        addLevelMove()
        addLifetimeMove()
    }

    func addWin() {
        getStatistic(name: "Lifetime Wins").increase()
    }

    func resetLevelMoves() {
        getStatistic(name: "Level Moves").reset()
    }

    // jx todo: change to load from storage
    func loadStatistics() {
        let stat1 = GameStatistic(name: "Level Moves", value: 0)
        let stat2 = GameStatistic(name: "Lifetime Moves", value: 0)
        let stat3 = GameStatistic(name: "Lifetime Wins", value: 0)
        let stats = [stat1, stat2, stat3]
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
        resetLevelMoves()
    }
}
