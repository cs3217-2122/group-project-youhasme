//
//  StopMechanic.swift
//  YouHasMe
//
//  Created by wayne on 30/3/22.
//

// Mechanic of STOP blocks
struct StopMechanic: GameMechanic {

    // Rejects movement of and into STOP blocks
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: Action, state: LevelLayerState) -> LevelLayerState {
        var newState = rejectMovementOfStop(state: state)
        newState = rejectMovementIntoStop(state: newState)
        return newState
    }

    // Rejects movement of STOP blocks
    private func rejectMovementOfStop(state: LevelLayerState) -> LevelLayerState {
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() where entityState.has(behaviour: .property(.stop)) {
            // Reject all move actions
            for action in entityState.getActions() {
                if case .move = action {
                    newState.entityStates[i].reject(action: action)
                }
            }
        }
        return newState
    }

    // Rejects movement into STOP blocks
    private func rejectMovementIntoStop(state: LevelLayerState) -> LevelLayerState {
        var newState = state
        let stopEntities = state.entitiesWith(behaviour: .property(.stop))
        for (i, entityState) in state.entityStates.enumerated() {
            for action in entityState.getActions() {
                guard case let .move(dx, dy) = action else {  // If action is move
                    continue
                }
                let newX = entityState.location.x + dx
                let newY = entityState.location.y + dy
                // Reject if moving into any STOP block
                if stopEntities.contains(where: { $0.location.isAt(x: newX, y: newY) }) {
                    newState.entityStates[i].reject(action: action)
                }
            }
        }
        return newState
    }

}
