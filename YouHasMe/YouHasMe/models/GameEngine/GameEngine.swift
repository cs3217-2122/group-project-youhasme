//
//  GameEngine.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

struct GameEngine {
    let gameMechanics = [MoveMechanic()]

    var levelLayer: LevelLayer

    // Updates game state given action
    mutating func update(action: UpdateAction) {
        var updates: [[Int]: [EntityAction]] = [:]  // Map of coordinates of entity to actions

        // Get updates of all mechanics
        for mechanic in gameMechanics {
            let newUpdates = mechanic.apply(update: action, levelLayer: levelLayer)
            updates.merge(newUpdates, uniquingKeysWith: { $0 + $1 })
        }

        // Get updates from mechanics
        var newLayer = levelLayer
        for r in 0..<levelLayer.dimensions.height {
            for c in 0..<levelLayer.dimensions.width {
                let entities = levelLayer.getTileAt(x: c, y: r).entities
                var newTile = Tile()
                // Copy unchanged entities
                for i in 0..<entities.count where updates[[r, c, i]] == nil {
                    newTile.entities.append(entities[i])
                }
                newLayer.setTileAt(x: c, y: r, tile: newTile)
            }
        }

        // Apply updates
        for (coords, actions) in updates {
            let y = coords[0]
            let x = coords[1]
            let i = coords[2]
            let entity = levelLayer.getTileAt(x: x, y: y).entities[i]
            for action in actions {
                switch action {
                case let .move(dx, dy):
                    newLayer.add(entity: entity, x: x + dx, y: y + dy)
                default:
                    break
                }

            }
        }

        levelLayer = RuleEngine().applyRules(to: newLayer)
    }
}
