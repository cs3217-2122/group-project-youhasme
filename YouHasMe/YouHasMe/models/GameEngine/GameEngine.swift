//
//  GameEngine.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

struct GameEngine {
    private let gameMechanics: [GameMechanic] = [
        PlayerMoveMechanic(), BoundaryMechanic(), PushMechanic(), WinMechanic(), StopMechanic(),
    ]
    private let ruleEngine = RuleEngine()

    private(set) var game: Game  // Current game state

    private(set) var status: GameEngineStatus = .running
    enum GameEngineStatus {
        case running
        case infiniteLoop  // Player has attempted to create infinite loop
    }

    init(levelLayer: LevelLayer) {
        game = Game(levelLayer: ruleEngine.applyRules(to: levelLayer))
    }

    // Updates game state given action
    mutating func apply(action: UpdateType) {
        status = .running
        // Repeatedly run simulation step until no more updates or infinite loop detected
        var previousStates = [game]
        var nextAction = action
        while true {
            let newState = step(game: previousStates.last ?? game, action: nextAction)
            if newState == previousStates.last {  // If reached steady state
                game = newState
                return
            } else if previousStates.contains(newState) {  // If returning to earlier states
                status = .infiniteLoop
                return
            }
            previousStates.append(newState)
            nextAction = .tick  // Apply .tick after first action
        }
    }

    // Runs single step of simulation and returns new game state
    private func step(game: Game, action: UpdateType) -> Game {
        var newGame = game
        let state = applyMechanics(action: action, levelLayer: game.levelLayer)  // Get updates
        newGame.levelLayer = resolveActions(in: state)  // Apply updates
        newGame.gameStatus = state.gameStatus
        return newGame
    }

    // Applies mechanics to level layer and returns resulting state with entities and their actions
    private func applyMechanics(action: UpdateType, levelLayer: LevelLayer) -> LevelLayerState {
        var curState = LevelLayerState(levelLayer: levelLayer)  // Initialise state from current level layer
        var oldState = curState
        // Apply all mechanics until there are no more changes to state (all mechanics agree on next set of actions)
        repeat {
            oldState = curState
            for mechanic in gameMechanics {
                curState = mechanic.apply(update: action, state: curState)
            }
        } while curState != oldState
        return applyConditions(state: curState)
    }

    // Remove intents with unmet conditions
    private func applyConditions(state: LevelLayerState) -> LevelLayerState {
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() {  // For each entity
            let newIntents = entityState.intents.filter {  // Remove intents with rejected conditions
                $0.conditionsMet(by: state)
            }
            newState.entityStates[i].intents = newIntents
        }
        return newState
    }

    // Applies actions and returns new level layer
    private func resolveActions(in state: LevelLayerState) -> LevelLayer {
        var newLayer = LevelLayer(dimensions: game.levelLayer.dimensions)
        for entityState in state.entityStates {
            var cur = entityState
            let location = cur.location
            if case let .move(dx, dy) = cur.popAction() {  // If we are moving entity
                newLayer.add(entity: cur.entity, x: location.x + dx, y: location.y + dy)
            } else {
                newLayer.add(entity: cur.entity, x: location.x, y: location.y)
            }
        }
        return ruleEngine.applyRules(to: newLayer)
    }
}
