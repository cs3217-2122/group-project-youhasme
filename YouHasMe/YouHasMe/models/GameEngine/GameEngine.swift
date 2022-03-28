//
//  GameEngine.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

struct GameEngine {
    let gameMechanics = [MoveMechanic()]

    var levelLayer: LevelLayer

    init(levelLayer: LevelLayer) {
        self.levelLayer = RuleEngine().applyRules(to: levelLayer)
    }

    // Updates game state given action
     mutating func update(action: UpdateType) {
        var updates: [Location: [EntityAction]] = [:]  // Map of coordinates of entity to actions
        // Get updates of all mechanics
        for mechanic in gameMechanics {
            let newUpdates = mechanic.apply(update: action, levelLayer: levelLayer)
            updates.merge(newUpdates, uniquingKeysWith: { $0 + $1 })
        }

        // Apply updates
        var newLayer = levelLayer
        // Copy unchanged entities
        for r in 0..<levelLayer.dimensions.height {
            for c in 0..<levelLayer.dimensions.width {
                let entities = levelLayer.getTileAt(x: c, y: r).entities
                var newTile = Tile()
                for i in 0..<entities.count where updates[Location(x: c, y: r, z: i)] == nil {
                    newTile.entities.append(entities[i])
                }
                newLayer.setTileAt(x: c, y: r, tile: newTile)
            }
        }
        // Add changed entities
        for (location, actions) in updates {
            let entity = levelLayer.getTileAt(x: location.x, y: location.y).entities[location.z]
            for action in actions {
                if case let .move(dx, dy) = action {  // If we are moving entity
                    newLayer.add(entity: entity, x: location.x + dx, y: location.y + dy)
                }
            }
        }

        levelLayer = RuleEngine().applyRules(to: newLayer)
    }
}
