//
//  BehaviourSystem.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents a game mechanic, such as the movement mechanic
protocol GameMechanic {

    // Applies mechanic to levelLayer
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - levelLayer: Current game state
    // Returns a map of location (x, y , position in tile) of entities to their actions
    func apply(update: UpdateAction, levelLayer: LevelLayer) -> [Location: [EntityAction]]

}
