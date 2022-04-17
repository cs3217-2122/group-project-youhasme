//
//  LevelLayerState.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Represents the state of a level layer while it is being updated by the game engine
struct LevelLayerState: Equatable {
    var dimensions: Rectangle
    var gameStatus: GameStatus = .inProgress
    var entityStates: [EntityState] = []

    init(levelLayer: LevelLayer) {
        dimensions = levelLayer.dimensions
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
    
    func playerEntities() -> [EntityState] {
        entityStates.filter {
            $0.isPlayer()
        }
    }

    // Returns entityStates of entities with specified behaviour
    func entitiesWith(behaviour: Behaviour) -> [EntityState] {
        entityStates.filter {
            $0.has(behaviour: behaviour)
        }
    }
}
