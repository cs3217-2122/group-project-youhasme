//
//  LevelLayerState.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Represents the state of a level layer while it is being updated by the game engine
struct LevelLayerState: Equatable {
    var dimensions: Rectangle
    var entityStates: [EntityState] = []
    // var gameState: GameState

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
}