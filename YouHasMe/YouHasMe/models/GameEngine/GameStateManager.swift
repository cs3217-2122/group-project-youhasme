//
//  GameStateManager.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 20/3/22.
//

import Foundation

struct GameStateManager {
    private var levelHistory: [Int: [LevelLayer]]
    private var levelLayerIndex: Int

    init(levelLayer: LevelLayer, levelLayerIndex: Int = 0) {
        self.levelHistory = [levelLayerIndex: [levelLayer]]
        self.levelLayerIndex = levelLayerIndex
    }

    mutating func addToLayerHistory(_ levelLayer: LevelLayer) {
        guard let latestLayer = levelHistory[levelLayerIndex]?.last else {
            levelHistory[levelLayerIndex] = [levelLayer]
            return
        }

        if latestLayer == levelLayer {
            return
        }

        // already checked in guard clause that history exists
        var history = levelHistory[levelLayerIndex]!
        history.append(levelLayer)
        levelHistory[levelLayerIndex] = history
    }

    mutating func getPreviousLayer() -> LevelLayer? {
        guard var history = levelHistory[levelLayerIndex] else {
            return nil
        }

        assert(history.count > 0, "State manager should not have empty history")
        if history.count == 1 {
            return history[0]
        }

        return history.popLast()
    }
}
