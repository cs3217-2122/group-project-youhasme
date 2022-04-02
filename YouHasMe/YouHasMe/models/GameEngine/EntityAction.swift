//
//  EntityAction.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents an Action an entity can take
enum EntityAction: Hashable {
    case move(dx: Int, dy: Int)  // Move by (dx, dy)

    // Returns new state after applying action
    func apply(on state: EntityState) -> EntityState {
        switch self {
        case let .move(dx, dy):
            return applyMove(state: state, dx: dx, dy: dy)
        }
    }

    private func applyMove(state: EntityState, dx: Int, dy: Int) -> EntityState {
        var newState = state
        newState.location.x += dx
        newState.location.y += dy
        return newState
    }
}
