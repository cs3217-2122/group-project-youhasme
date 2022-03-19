//
//  UpdateAction.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents type of update to game state
enum UpdateAction {
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
}
