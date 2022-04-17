//
//  EntityAction.swift
//  YouHasMe
//
//  Created by wayne on 19/3/22.
//

// Represents an action an entity can take
enum EntityAction: Hashable {
    case move(dx: Int, dy: Int)  // Move by (dx, dy)
    case transform(target: Noun)  // Tranform entity type to target
    case destroy  // Remove entity
    case spawn(Noun)
}
