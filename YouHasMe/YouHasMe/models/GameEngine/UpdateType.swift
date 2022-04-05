//
//  UpdateType.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents type of update to game state

protocol UpdateType {
    func getMovement() -> (Int, Int)
    func getPlayer() -> Int
    func getAction() -> UpdateAction
    mutating func setAction(_: UpdateAction)
}

struct Move: UpdateType {
    var playerNum: Int = 1
    var updateAction: UpdateAction

    func getMovement() -> (Int, Int) {
        updateAction.getMovement()
    }

    func getPlayer() -> Int {
        playerNum
    }

    func getAction() -> UpdateAction {
        updateAction
    }

    mutating func setAction(_ action: UpdateAction) {
        updateAction = action
    }
}

enum UpdateAction: String, Codable {
    case moveUp
    case moveDown
    case moveLeft
    case moveRight
    case tick  // No movement
    case undo

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
