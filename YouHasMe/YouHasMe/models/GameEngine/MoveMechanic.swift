//
//  PlayerMoveMechanic.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents player controlled movement mechanic
struct PlayerMoveMechanic: GameMechanic {

    // Applies player controlled movement mechanic to current state
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState {
        let (dx, dy) = update.getMovement()
        guard dx != 0 || dy != 0 else {
            return state  // Return original state if no movement
        }

        // Move all you blocks
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() where entityState.has(behaviour: .property(.you)) {
            newState.entityStates[i].add(action: .move(dx: dx, dy: dy))
        }

        return newState
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
