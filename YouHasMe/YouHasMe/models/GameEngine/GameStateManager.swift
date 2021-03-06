//
//  GameStateManager.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 20/3/22.
//

import Foundation

/**
 Keeps track of the visited states of a single Level (that can have one or more LevelLayers).
 May need to undergo some changes depending on what is allowed between LevelLayers
 or if we are even going to implement different layers.
 Assumes that between LevelLayers, the GameStateManager should stay the same.
 Between Levels, the GameStateManager should be re-initalised.
 */
struct GameStateManager {
    private var initialState: Game
    private var levelHistory: [Int: [Game]]
    private var levelLayerIndex: Int

    var currentState: Game {
        levelHistory[levelLayerIndex]?.last ?? initialState
    }

    init(levelLayer: LevelLayer, levelLayerIndex: Int = 0) {
        initialState = Game(levelLayer: levelLayer)
        self.levelHistory = [levelLayerIndex: [initialState]]
        self.levelLayerIndex = levelLayerIndex
    }

    mutating func push(_ game: Game) {
        guard let latest = levelHistory[levelLayerIndex]?.last else {
            levelHistory[levelLayerIndex] = [game]
            return
        }

        if latest == game {
            return
        }

        // already checked in guard clause that history exists
        var history = levelHistory[levelLayerIndex]!
        history.append(game)
        levelHistory[levelLayerIndex] = history
    }

    mutating func undo() -> Game? {
        guard var history = levelHistory[levelLayerIndex] else {
            return nil
        }

        assert(
            !history.isEmpty,
            "State manager should not have empty history at any layer entered before.")
        if history.count == 1 {
            return history[0]
        }

        _ = history.popLast()
        levelHistory[levelLayerIndex] = history
        return history.last
    }
}
