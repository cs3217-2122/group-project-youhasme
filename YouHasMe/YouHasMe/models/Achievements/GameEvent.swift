//
//  GameEvent.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import Foundation

class GameEvent {
    enum type: Int {
        case MOVE = 0
        case WIN = 1
    }

    var type: GameEvent.type
    var entityType: EntityType?

    init(type: GameEvent.type, entityType: EntityType? = nil) {
        self.type = type
        self.entityType = entityType
    }
}
