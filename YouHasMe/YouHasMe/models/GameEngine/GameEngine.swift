//
//  GameEngine.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

struct GameEngine {
    let gameMechanics = [MoveMechanic()]

    var levelLayer: LevelLayer

    // Updates game state given action
    func update(action: UpdateAction) {
        var updates: [[Int]: [EntityAction]] = [:]  // Map of coordinates of entity to actions
        for mechanic in gameMechanics {
            let newUpdates = mechanic.apply(update: action, levelLayer: levelLayer)
            updates.merge(newUpdates, uniquingKeysWith: { $0 + $1 })
        }
    }
}
