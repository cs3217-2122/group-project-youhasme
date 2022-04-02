//
//  EntityEventDecorator.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 3/4/22.
//

import Foundation

class EntityEventDecorator: GameEventBaseDecorator {
    var entityType: EntityType

    init(wrappedEvent: AbstractGameEvent, entityType: EntityType) {
        self.entityType = entityType
        super.init(wrappedEvent: wrappedEvent)
    }

    override func hasEntity(entityType: EntityType) -> Bool {
        self.entityType == entityType || wrappedEvent.hasEntity(entityType: entityType)
    }
}
