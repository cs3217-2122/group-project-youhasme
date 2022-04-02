//
//  TransformMechanic.swift
//  YouHasMe
//
//  Created by wayne on 2/4/22.
//

// Mechanic to handle transformation though NOUN IS NOUN
struct TransformMechanic: GameMechanic {

    // Adds transform action to entities
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState {
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() {
            for behaviour in entityState.entity.activeBehaviours {
                if case let .bIs(target) = behaviour {
                    newState.entityStates[i].add(action: .transform(target: target))
                }
            }
        }
        return newState
    }

}
