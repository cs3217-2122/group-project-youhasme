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
        let coordsOfYou = getCoordsOfYou(levelLayer: levelLayer)  // Coordinates of YOU blocks

        // Get coordinates of blocks that are moved
        var coordsMoved: Set<[Int]> = []
        let (dx, dy) = update.getMovement()
        for coords in coordsOfYou {  // For each you block
            let newCoords = getMovedByYou(levelLayer: levelLayer, youCoords: coords, dy: dy, dx: dx)
            coordsMoved = coordsMoved.union(newCoords)
        }

        // Return map of coordinates to move action
        var actions: [[Int]: [EntityAction]] = [:]
        for coords in coordsMoved {
            actions[coords] = [.move(dx, dy)]
        }
        return actions
    }

    // Get coordinates of YOU blocks
    private func getCoordsOfYou(levelLayer: LevelLayer) -> Set<[Int]> {
        var coordsOfYou: Set<[Int]> = []
        for r in 0..<levelLayer.dimensions.height {
            for c in 0..<levelLayer.dimensions.width {
                let entities = levelLayer.getTileAt(x: c, y: r).entities
                for i in 0..<entities.count where entities[i].activeBehaviours.contains(.property(.you)) {
                    coordsOfYou.insert([r, c, i])
                }
            }
        }
        return coordsOfYou
    }

    // Get coordinates of line of blocks moved by a YOU block
    private func getMovedByYou(levelLayer: LevelLayer, youCoords: [Int], dy: Int, dx: Int) -> Set<[Int]> {
        var coordsMightMove: Set<[Int]> = [youCoords]  // Coordinates of YOU block and line of blocks that are pushed
        var curY = youCoords[0] + dy
        var curX = youCoords[1] + dx
        while levelLayer.isWithinBounds(x: curX, y: curY) {  // While we have space to move
            let entities = levelLayer.getTileAt(x: curX, y: curY).entities
            var foundPushable = false
            // Add pushable entities in current tile
            for i in 0..<entities.count where entities[i].activeBehaviours.contains(.property(.push)) {
                coordsMightMove.insert([curY, curX, i])
                foundPushable = true
            }

            if !foundPushable {  // Empty space found, return line of blocks moved
                return coordsMightMove
            }
            curY += dy
            curX += dx
        }
        return []  // Reached edge of level, blocked by level wall, nothing moves
    }

}
