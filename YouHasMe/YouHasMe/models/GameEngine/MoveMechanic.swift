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
        // Get coordinates of YOU blocks
        var coordsOfYou: Set<[Int]> = []
        for r in 0..<levelLayer.dimensions.height {
            for c in 0..<levelLayer.dimensions.width {
                let entities = levelLayer.getTileAt(x: c, y: r).entities
                for i in 0..<entities.count where entities[i].activeBehaviours.contains(.property(.you)) {
                    coordsOfYou.insert([r, c, i])
                }
            }
        }

        // Get coordinates of blocks that will move
        var coordsWillMove: Set<[Int]> = []
        let (dx, dy) = update.getMovement()
        for coords in coordsOfYou {  // For each you block
            var coordsMightMove: Set<[Int]> = [coords]  // Coordinates of YOU blocks or blocks that are pushed
            var curY = coords[0] + dy
            var curX = coords[1] + dx
            while levelLayer.isWithinBounds(x: curX, y: curY) {  // While we have space to move
                let entities = levelLayer.getTileAt(x: curX, y: curY).entities
                var foundPushable = false
                // Add pushable entities
                for i in 0..<entities.count where entities[i].activeBehaviours.contains(.property(.push)) {
                    coordsMightMove.insert([curY, curX, i])
                    foundPushable = true
                }

                if !foundPushable {  // Empty space found, can move chain of blocks
                    coordsWillMove = coordsWillMove.union(coordsMightMove)
                }

                curY += dy
                curX += dx
            }
        }

        // Return map of coordinates to move action
        var actions: [[Int]: [EntityAction]] = [:]
        for coords in coordsWillMove {
            actions[coords] = [.move(dx, dy)]
        }
        return actions
    }

}
