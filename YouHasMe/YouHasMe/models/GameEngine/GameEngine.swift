//
//  GameEngine.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

struct GameEngine {
    let gameMechanics = [PlayerMoveMechanic()]
    let ruleEngine = RuleEngine()

    var levelLayer: LevelLayer

    init(levelLayer: LevelLayer) {
        self.levelLayer = ruleEngine.applyRules(to: levelLayer)
    }

    // Updates game state given action
    mutating func step(action: UpdateType) {
        var state = LevelLayerState(levelLayer: levelLayer)
        for mechanic in gameMechanics {
            state = mechanic.apply(update: action, state: state)
        }

        // Apply updates
        var newLayer = LevelLayer(dimensions: levelLayer.dimensions)
        for entityState in state.entityStates {
            var cur = entityState
            let location = cur.location
            if case let .move(dx, dy) = cur.popAction() {  // If we are moving entity
                newLayer.add(entity: cur.entity, x: location.x + dx, y: location.y + dy)
            } else {
                newLayer.add(entity: cur.entity, x: location.x, y: location.y)
            }
        }

        levelLayer = ruleEngine.applyRules(to: newLayer)
    }
}
