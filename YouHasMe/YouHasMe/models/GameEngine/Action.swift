//
//  UpdateType.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents type of update to game state

struct Action {
    var playerNum: Int = 1
    var actionType: ActionType
    
    func getMovement() -> (Int, Int) {
        actionType.getMovement()
    }
    
    func getMovementAsVector() -> Vector {
        actionType.getMovementAsVector()
    }
}

enum ActionType {
    case moveUp
    case moveDown
    case moveLeft
    case moveRight
    case tick  // No movement

    // Returns (dx, dy)
    func getMovement() -> (Int, Int) {
        switch self {
        case .moveLeft:
            return (-1, 0)
        case .moveRight:
            return (1, 0)
        case .moveUp:
            return (0, -1)
        case .moveDown:
            return (0, 1)
        default:
            return (0, 0)
        }
    }

    func getMovementAsVector() -> Vector {
        let movement = getMovement()
        return Vector(dx: movement.0, dy: movement.1)
    }
}
