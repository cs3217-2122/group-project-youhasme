//
//  HasMechanic.swift
//  YouHasMe
//
//  Created by wayne on 17/4/22.
//

// Mechanic to handle HAS
struct HasMechanic: GameMechanic {

    // When destroyed entity HAS an entity, spawn that entity
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState {
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() {
            // Check that entity is being destroyed
            guard entityState.getActions().contains(.destroy) else {
                continue
            }
            // Spawn HAS target
            for behaviour in entityState.entity.activeBehaviours {
                if case let .bHas(target) = behaviour {
                    newState.entityStates[i].add(
                        action: .spawn(target), ifEntityAt: entityState.location, performs: .destroy)
                }
            }
        }
        return newState
    }

}
