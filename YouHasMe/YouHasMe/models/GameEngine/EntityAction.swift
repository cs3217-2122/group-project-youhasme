//
//  EntityAction.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents what happens to entity after updating game state
enum EntityAction {
    case move(Int, Int)  // Move by (dx, dy)
    case destroy  // Remove from level
    case win
    case defeat
}