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
    func apply(update: UpdateType, levelLayer: LevelLayer) -> [Location: [EntityAction]]

    // func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState
}

// Represents the state of a level layer while it is being updated by the game engine
struct LevelLayerState {
    var entityStates: Set<EntityState> = []
    // var gameState: GameState
}

// Represents the state of an entity while it is being updated by the game engine
struct EntityState: Hashable {
    var entity: Entity
    var location: Location
    var intents: Set<EntityIntent> = []
}

// Represents an intent to perform an entity action
struct EntityIntent: Hashable {
    var isRejected = false
    var action: EntityAction
}
