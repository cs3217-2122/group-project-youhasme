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

    override func containsGameEvent(event: AbstractGameEvent) -> Bool {
        event.isContainedBy(gameEvent: self)
    }

    override func isContainedBy(gameEvent: AbstractGameEvent) -> Bool {
        gameEvent.hasEntity(entityType: entityType) && wrappedEvent.isContainedBy(gameEvent: gameEvent)
    }

    override func toPersistable() -> PersistableAbstractGameEvent {
        let persistable = wrappedEvent.toPersistable()
        persistable.setEntityType(entityType)
        return persistable
    }
}
