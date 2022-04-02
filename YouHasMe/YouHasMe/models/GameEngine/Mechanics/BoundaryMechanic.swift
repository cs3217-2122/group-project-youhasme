//
//  BoundaryMechanic.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Mechanic to prevent movement beyond level bounds
struct BoundaryMechanic: GameMechanic {

    // Applies mechanic to current state
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState {
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() {  // For each entity
            for action in entityState.getActions() {
                guard case let .move(dx, dy) = action else {  // If action is move
                    continue
                }
                let newX = entityState.location.x + dx
                let newY = entityState.location.y + dy
                if !state.dimensions.isWithinBounds(x: newX, y: newY) {  // If moving out of bounds
                    newState.entityStates[i].reject(action: action)
                }
            }
        }
        return newState
    }

}
