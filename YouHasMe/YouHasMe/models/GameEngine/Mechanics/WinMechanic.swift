//
//  WinMechanic.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Mechanic to handle winning of game
struct WinMechanic: GameMechanic {

    // Sets game status to won when WIN block overlaps with YOU block
    //
    // Parameters:
    //  - update: What triggered the update (e.g. user moves right)
    //  - state: Current game state
    // Returns new state containing updates triggered by mechanic
    func apply(update: UpdateType, state: LevelLayerState) -> LevelLayerState {
        let youEntities = state.entitiesWith(behaviour: .property(.you))
        let winEntities = state.entitiesWith(behaviour: .property(.win))
        let playerEntities = state.playerEntities()

        // Check for overlap of any YOU block with any WIN block
        var newState = state
        for youEntity in youEntities {
            let youLocation = youEntity.location
            if winEntities.contains(where: { $0.location.isOverlapping(with: youLocation) }) {
                newState.gameStatus = .win
            }
        }

        for playerEntity in playerEntities {
            let playerLocation = playerEntity.location
            if winEntities.contains(where: { $0.location.isOverlapping(with: playerLocation) }) {
                newState.gameStatus = .win
            }
        }
        return newState
    }

}
