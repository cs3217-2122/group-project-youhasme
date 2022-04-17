//
//  PlayerMoveMechanic.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents player controlled movement mechanic
struct PlayerMoveMechanic: GameMechanic {

    // Applies player controlled movement mechanic to current state
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: Action, state: LevelLayerState) -> LevelLayerState {
        let (dx, dy) = update.getMovement()
        let player = update.playerNum
        guard dx != 0 || dy != 0 else {
            return state  // Return original state if no movement
        }

        // Move all YOU blocks
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() where entityState.has(behaviour: .property(.you)) {
            newState.entityStates[i].add(action: .move(dx: dx, dy: dy))
        }
        for (i, entityState) in state.entityStates.enumerated()
            where entityState.has(behaviour: .property(.player(player))) {
            newState.entityStates[i].add(action: .move(dx: dx, dy: dy))
        }
        return newState
    }
}
