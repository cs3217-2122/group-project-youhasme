//
//  BoundaryMechanic.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Mechanic to prevent movement beyond level bounds
struct BoundaryMechanic: GameMechanic {
    weak var publishingDelegate: AbstractGameEngineEventPublishingDelegate?

    // Applies mechanic to current state
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: Action, state: LevelLayerState) -> LevelLayerState {
        var newState = state
        for (i, entityState) in state.entityStates.enumerated() {  // For each entity
            for action in entityState.getActions() {
                guard case let .move(dx, dy) = action else {  // If action is move
                    continue
                }
                let newX = entityState.location.x + dx
                let newY = entityState.location.y + dy
                let isYouTryingToCrossBoundary = entityState.has(behaviour: .property(.you))
                let isPlayerTryingToCrossBoundary = entityState.has(behaviour: .property(.player(update.playerNum)))
                if !state.dimensions.isWithinBounds(x: newX, y: newY) {  // If moving out of bounds
                    if isYouTryingToCrossBoundary {
                        publishingDelegate?.send(GameEvent(type: .movingAcrossLevel(playerNum: 0)))
                    } else if isPlayerTryingToCrossBoundary {
                        publishingDelegate?.send(GameEvent(type: .movingAcrossLevel(playerNum: update.playerNum)))
                    }
                    newState.entityStates[i].reject(action: action)
                }
            }
        }
        return newState
    }

}
