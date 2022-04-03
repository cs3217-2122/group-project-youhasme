//
//  MultiplayerMechanic.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation

struct MultiplayerMechanic: GameMechanic {

    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState {
        // Move all YOU blocks
        let playerNum = update.getPlayer()
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() where entityState.has(behaviour: .property(.player(playerNum))) {
            newState.entityStates[i].add(behaviour: .property(.you))
            newState.entityStates[i].remove(behaviour: .property(.player(playerNum)))
        }
        return newState
    }
}
