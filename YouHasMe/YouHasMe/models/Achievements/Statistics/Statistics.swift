//
//  MoveStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 31/3/22.
//

import Foundation

class Statistics: Codable {
    // jx todo: change to dictionary
    var gameStatistics: [GameStatistic] = []

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

    func loadStatistics() {
        let stat1 = GameStatistic(id: 1, name: "Level Moves", value: 0)
        let stat2 = GameStatistic(id: 2, name: "Lifetime Moves", value: 0)
        let stat3 = GameStatistic(id: 3, name: "Lifetime Wins", value: 0)
        gameStatistics = [stat1, stat2, stat3]
    }

    func getStatistic(name: String) -> GameStatistic {
        guard let stat = gameStatistics.first(where: { $0.name == name }) else {
            assert(false, "Game statistic \(name) does not exist")
        }

        return stat
    }
}
