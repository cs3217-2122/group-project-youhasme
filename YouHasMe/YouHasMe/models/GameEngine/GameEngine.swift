//
//  GameEngine.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

import Combine

struct GameEngine: GameEventPublisher {
    let gameMechanics: [GameMechanic] = [PlayerMoveMechanic(), BoundaryMechanic(), PushMechanic()]
    let ruleEngine = RuleEngine()
    var gameEventPublisher: AnyPublisher<GameEvent, Never> {
        gameEventSubject.eraseToAnyPublisher()
    }

    private let gameEventSubject = PassthroughSubject<GameEvent, Never>()

    var levelLayer: LevelLayer

    init(levelLayer: LevelLayer) {
        self.levelLayer = ruleEngine.applyRules(to: levelLayer)
    }

    // Updates game state given action
    mutating func step(action: UpdateType) {
        let state = applyMechanics(action: action)

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

    // Applies mechanics to level layer and returns resulting state with entities and their actions
    private func applyMechanics(action: UpdateType) -> LevelLayerState {
        var curState = LevelLayerState(levelLayer: levelLayer)  // Initialise state from current level layer
        var oldState = curState
        let originalState = curState

        // Apply all mechanics until there are no more changes to state
        repeat {
            oldState = curState
            for mechanic in gameMechanics {
                curState = mechanic.apply(update: action, state: curState)
            }
        } while curState != oldState

        if curState != originalState {
            gameEventSubject.send(GameEvent(type: .MOVE))
        }

        return curState
    }
}
