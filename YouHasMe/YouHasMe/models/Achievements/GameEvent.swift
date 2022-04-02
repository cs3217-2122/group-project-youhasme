//
//  GameEvent.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import Foundation

class GameEvent {
    enum type: Int {
        case move
        case win
        case designLevel
    }

    var type: GameEvent.type
    var entityType: EntityType?

    init(type: GameEvent.type, entityType: EntityType? = nil) {
        self.type = type
        self.entityType = entityType
    }
}
