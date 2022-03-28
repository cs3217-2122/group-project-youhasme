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
    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState
}

// Represents the state of a level layer while it is being updated by the game engine
struct LevelLayerState {
    var entityStates: [EntityState] = []
    // var gameState: GameState

    init(levelLayer: LevelLayer) {
        for y in 0..<levelLayer.dimensions.height {
            for x in 0..<levelLayer.dimensions.width {
                let entities = levelLayer.getTileAt(x: x, y: y).entities
                for z in 0..<entities.count {
                    let location = Location(x: x, y: y, z: z)
                    entityStates.append(EntityState(entity: entities[z], location: location))
                }
            }
        }
    }
}

// Represents the state of an entity while it is being updated by the game engine
struct EntityState: Hashable {
    var entity: Entity
    var location: Location
    var intents: Set<EntityIntent> = []

    func has(behaviour: Behaviour) -> Bool {
        entity.has(behaviour: behaviour)
    }

    // Adds intent to perform action if not already present
    mutating func add(action: EntityAction) {
        guard intents.allSatisfy({ $0.action != action }) else {
            return  // Intent already added
        }
        intents.insert(EntityIntent(action: action))
    }

    // Returns next action to be performed or nil if there is no such action
    mutating func popAction() -> EntityAction? {
        let nextIntent = intents.first { !$0.isRejected } // First unrejected intent
        guard let intent = nextIntent else {
            return nil // No unrejected actions
        }
        intents.remove(intent)
        return intent.action
    }
}

// Represents an intent to perform an entity action
struct EntityIntent: Hashable {
    var isRejected = false
    var action: EntityAction
}
