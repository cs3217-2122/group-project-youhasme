//
//  SinkMechanic.swift
//  YouHasMe
//
//  Created by wayne on 17/4/22.
//

// Mechanic of SINK blocks
struct SinkMechanic: GameMechanic {

    // If SINK entity overlaps with another entity, destroy both
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState {
        var newState = state
        for (i, sinkEntity) in state.entityStates.enumerated() where sinkEntity.has(behaviour: .property(.sink)) {
            for (j, entity) in state.entityStates.enumerated() {
                // If sink entity is overlapping with other entity
                if sinkEntity != entity && sinkEntity.location.isOverlapping(with: entity.location) {
                    //  Destroy both
                    newState.entityStates[i].add(action: .destroy)
                    newState.entityStates[j].add(action: .destroy)
                }
            }
        }
        return newState
    }
}
