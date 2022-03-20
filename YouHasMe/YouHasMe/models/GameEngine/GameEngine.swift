//
//  GameEngine.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

struct GameEngine {
    let gameMechanics = [MoveMechanic()]

    private var gameStateManager: GameStateManager
    var levelLayer: LevelLayer

    init(levelLayer: LevelLayer) {
        self.levelLayer = levelLayer
        self.gameStateManager = GameStateManager(levelLayer: levelLayer)
    }

    // Updates game state given action
    mutating func update(action: UpdateAction) {
        if action == .undo {
            performUndo()
            return
        }

        var updates: [[Int]: [EntityAction]] = [:]  // Map of coordinates of entity to actions

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
                for i in 0..<entities.count where updates[[r, c, i]] == nil {
                    newTile.entities.append(entities[i])
                }
                newLayer.setTileAt(x: c, y: r, tile: newTile)
            }
        }
        // Add changed entities
        for (coords, actions) in updates {
            let y = coords[0]
            let x = coords[1]
            let i = coords[2]
            let entity = levelLayer.getTileAt(x: x, y: y).entities[i]
            for action in actions {
                if case let .move(dx, dy) = action { // If we are moving entity
                    newLayer.add(entity: entity, x: x + dx, y: y + dy)
                }
            }
        }

        levelLayer = RuleEngine().applyRules(to: newLayer)
        gameStateManager.addToLayerHistory(levelLayer)
    }

    private mutating func performUndo() {
        guard let previousLayer = gameStateManager.getPreviousLayer() else {
            return
        }

        levelLayer = previousLayer
    }
}
