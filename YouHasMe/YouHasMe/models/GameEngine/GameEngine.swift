//
//  GameEngine.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

import Combine

protocol AbstractGameEngineEventPublishingDelegate: GameEventPublisher, AnyObject {
    func send(_ gameEvent: AbstractGameEvent)
}

class GameEngineEventPublishingDelegate: AbstractGameEngineEventPublishingDelegate {
    var gameEventPublisher: AnyPublisher<AbstractGameEvent, Never> {
        gameEventSubject.eraseToAnyPublisher()
    }

    private let gameEventSubject = PassthroughSubject<AbstractGameEvent, Never>()
    func send(_ gameEvent: AbstractGameEvent) {
        gameEventSubject.send(gameEvent)
    }
}

struct GameEngine: GameEventPublisher {
    var gameEventPublisher: AnyPublisher<AbstractGameEvent, Never> {
        publishingDelegate.gameEventPublisher
    }

    var publishingDelegate: AbstractGameEngineEventPublishingDelegate = GameEngineEventPublishingDelegate()
    var lastActiveRulesPublisher: AnyPublisher<[Rule], Never> {
        ruleEngine.lastActiveRulesPublisher
    }
    private let gameMechanics: [GameMechanic]
    private let ruleEngine: RuleEngine

    private var gameStateManager: GameStateManager
    var currentGame: Game {
        gameStateManager.currentState
    }

    private(set) var status: GameEngineStatus = .running
    enum GameEngineStatus {
        case running
        case infiniteLoop  // Player has attempted to create infinite loop
    }

    init(levelLayer: LevelLayer, ruleEngineDelegate: RuleEngineDelegate? = nil) {
        self.ruleEngine = RuleEngine(ruleEngineDelegate: ruleEngineDelegate)
        gameStateManager = GameStateManager(levelLayer: ruleEngine.applyRules(to: levelLayer))
        gameMechanics = [
            PlayerMoveMechanic(),
            BoundaryMechanic(publishingDelegate: publishingDelegate),
            PushMechanic(),
            WinMechanic(),
            StopMechanic(),
            TransformMechanic(),
            SinkMechanic(),
            HasMechanic()
        ]
    }

    mutating func undo() {
        _ = gameStateManager.undo()
        _ = ruleEngine.applyRules(to: gameStateManager.currentState.levelLayer)
    }

    // Updates game state given action
    mutating func apply(action: UpdateType) {
        status = .running
        // Repeatedly run simulation step until no more updates or infinite loop detected
        var previousStates = [currentGame]
        var nextAction = action
        let originalState = currentGame

        while true {
            let newState = step(game: previousStates.last ?? currentGame, action: nextAction)
            if newState == previousStates.last {  // If reached steady state
                gameStateManager.push(newState)
                sendGameEvents(oldState: originalState, newState: newState)
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
        var curState = state
        var oldState = curState
        repeat {  // Repeat until no more changes
            oldState = curState
            for (i, entityState) in curState.entityStates.enumerated() {  // For each entity
                // Remove intents with rejected conditions
                let newIntents = entityState.intents.filter { $0.conditionsMet(by: curState) }
                curState.entityStates[i].intents = newIntents
            }
        } while curState != oldState
        return curState
    }

    // Applies actions and returns new level layer
    private func resolveActions(in state: LevelLayerState) -> LevelLayer {
        var newLayer = LevelLayer(dimensions: currentGame.levelLayer.dimensions)
        for entityState in state.entityStates {
            // Apply actions to entity
            let compoundAction = CompoundEntityAction(actions: entityState.getActions())
            let newStates = compoundAction.apply(state: entityState)
            for state in newStates {
                // Add resulting entities game board
                newLayer.add(entity: state.entity, x: state.location.x, y: state.location.y)
            }
        }
        return ruleEngine.applyRules(to: newLayer)
    }

    private func sendGameEvents(oldState: Game, newState: Game) {
        sendMoveGameEvent(oldState: oldState, newState: newState)
        sendWinGameEvent(newState: newState)
    }

    private func sendMoveGameEvent(oldState: Game, newState: Game) {
        if oldState == newState {
            return
        }

        let event = GameEvent(type: .move)
        var entityTypes: Set<EntityType> = []
        for entityState in LevelLayerState(levelLayer: oldState.levelLayer)
                .entityStates where entityState.has(behaviour: .property(.you)) {
            entityTypes.insert(entityState.entity.entityType)
        }
        publishingDelegate.send(
            EntityEventDecorator(wrappedEvent: event, entityTypes: entityTypes)
        )
    }

    private func sendWinGameEvent(newState: Game) {
        if !(newState.gameStatus == .win) {
            return
        }
        let event = GameEvent(type: .win)
        var entityTypes: Set<EntityType> = []
        for entityState in LevelLayerState(levelLayer: newState.levelLayer)
                .entityStates where entityState.has(behaviour: .property(.you)) {
            entityTypes.insert(entityState.entity.entityType)
        }
        publishingDelegate.send(
            EntityEventDecorator(wrappedEvent: event, entityTypes: entityTypes)
        )
    }
}
