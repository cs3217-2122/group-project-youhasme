//
//  PushMechanic.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Mechanic to allow for pushing of blocks
struct PushMechanic: GameMechanic {

    // Applies push mechanic to current state, may cause rejection of move action of pushing entity
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState {
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() {  // For each entity
            for action in entityState.getActions() {
                // If action is move
                guard case let .move(dx, dy) = action else {
                    continue
                }
                // Move blocks at new location
                let canPush = tryPush(state: &newState, from: entityState.location, dx: dx, dy: dy)
                // Reject action if blocks at new location cannot be moved
                if !canPush {
                    newState.entityStates[i].reject(action: action)
                }
            }
        }
        return newState
    }

    // Pushes blocks at new location by adding move actions to them, returns false if actions are rejected
    private func tryPush(state: inout LevelLayerState, from start: Location, dx: Int, dy: Int) -> Bool {
        let newX = start.x + dx
        let newY = start.y + dy
        let move: EntityAction = .move(dx: dx, dy: dy)
        for (i, entityState) in state.entityStates.enumerated() {  // For each entity
            // Filter pushable blocks at new location
            guard entityState.location.isAt(x: newX, y: newY) && entityState.has(behaviour: .property(.push)) else {
                continue
            }
            if entityState.hasRejected(action: move) {
                return false  // Action already rejected
            }
            state.entityStates[i].add(action: move, ifEntityAt: start, performs: move)  // Push entity
        }
        return true
    }

}
