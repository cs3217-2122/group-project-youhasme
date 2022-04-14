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

    func hasSameEntity(_ otherEntityEventDecorator: EntityEventDecorator) -> Bool {
        entityType == otherEntityEventDecorator.entityType
    }

    override func hasSameDecoratedDetails(otherGameEvent: AbstractGameEvent) -> Bool {
        entityTypeIsContainedBy(otherGameEvent: otherGameEvent)
    }

    func entityTypeIsContainedBy(otherGameEvent: AbstractGameEvent) -> Bool {
        if let entityEvent = otherGameEvent as? EntityEventDecorator {
            if hasSameEntity(entityEvent) {
                return true
            }
        }
        if let decoratedEvent = otherGameEvent as? GameEventBaseDecorator {
            return entityTypeIsContainedBy(otherGameEvent: decoratedEvent.wrappedEvent)
        }
        return false
    }

    override func toPersistable() -> PersistableAbstractGameEvent {
        let persistable = wrappedEvent.toPersistable()
        persistable.setEntityType(entityType)
        return persistable
    }
}
