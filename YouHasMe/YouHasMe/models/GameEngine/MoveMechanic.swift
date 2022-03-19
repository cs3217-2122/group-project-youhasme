//
//  MoveSystem.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents player controlled movement mechanic
struct MoveMechanic: GameMechanic {

    // Applies player controlled movement mechanic to levelLayer
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - levelLayer: Current game state
    // Returns a map of coordinates (y, x, position in tile) of entities to their actions
    func apply(update: UpdateAction, levelLayer: LevelLayer) -> [[Int]: [EntityAction]] {
        var dict: [[Int]: [EntityAction]] = [:]
        let (dx, dy) = update.getMovement()
        for r in 0..<levelLayer.dimensions.height {
            for c in 0..<levelLayer.dimensions.width {
                let entities = levelLayer.getTileAt(x: c, y: r).entities
                for i in 0..<entities.count where entities[i].activeBehaviours.contains(.property(.you)) {
                    dict[[r, c, i]] = [.move(dx, dy)]
                }
            }
        }
        return dict
    }

}
