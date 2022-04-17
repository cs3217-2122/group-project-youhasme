//
//  BehaviourSystem.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents a game mechanic, such as the movement mechanic
protocol GameMechanic {

    // Applies mechanic to current state
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: Action, state: LevelLayerState) -> LevelLayerState
}
