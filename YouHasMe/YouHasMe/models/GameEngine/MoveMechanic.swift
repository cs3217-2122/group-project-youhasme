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
    // Returns a map of location (x, y , position in tile) of entities to their actions
    func apply(update: UpdateAction, levelLayer: LevelLayer) -> [Location: [EntityAction]] {
        let (dx, dy) = update.getMovement()
        guard dx != 0 || dy != 0 else {
            return [:]
        }

        let youLocations = levelLayer.getLocationsOf(behaviour: .property(.you))  // Coordinates of YOU blocks

        // Get coordinates of blocks that are moved
        var locationsMoved: Set<Location> = []
        for location in youLocations {  // For each you block
            let newLocations = getMovedByYou(levelLayer: levelLayer, youLocation: location, dy: dy, dx: dx)
            locationsMoved = locationsMoved.union(newLocations)
        }

        // Return map of coordinates to move action
        var actions: [Location: [EntityAction]] = [:]
        for location in locationsMoved {
            actions[location] = [.move(dx: dx, dy: dy)]
        }
        return actions
    }

    // Get coordinates of line of blocks moved by a YOU block
    private func getMovedByYou(levelLayer: LevelLayer, youLocation: Location, dy: Int, dx: Int) -> Set<Location> {
        var locationsMightMove: Set<Location> = [youLocation]  // Locations of YOU and pushed line of blocks
        var curY = youLocation.y + dy
        var curX = youLocation.x + dx
        while levelLayer.isWithinBounds(x: curX, y: curY) {  // While we have space to move
            let entities = levelLayer.getTileAt(x: curX, y: curY).entities
            var foundPushable = false
            // Add pushable entities in current tile
            for i in 0..<entities.count where entities[i].activeBehaviours.contains(.property(.push)) {
                locationsMightMove.insert(Location(x: curX, y: curY, z: i))
                foundPushable = true
            }

            if !foundPushable {  // Empty space found, return line of blocks moved
                return locationsMightMove
            }
            curY += dy
            curX += dx
        }
        return []  // Reached edge of level, blocked by level wall, nothing moves
    }

}
