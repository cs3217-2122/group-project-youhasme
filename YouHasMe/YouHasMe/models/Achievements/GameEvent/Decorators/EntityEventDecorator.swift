//
//  EntityEventDecorator.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 3/4/22.
//

import Foundation

class EntityEventDecorator: GameEventBaseDecorator {
    var entityTypes: Set<EntityType>

    convenience init(wrappedEvent: AbstractGameEvent, entityType: EntityType) {
        self.init(wrappedEvent: wrappedEvent, entityTypes: [entityType])
    }

    init(wrappedEvent: AbstractGameEvent, entityTypes: Set<EntityType>) {
        self.entityTypes = entityTypes
        super.init(wrappedEvent: wrappedEvent)
    }

    func entityTypesAreContainedBy(_ otherEntityEventDecorator: EntityEventDecorator) -> Bool {
        entityTypes.isSubset(of: otherEntityEventDecorator.entityTypes)
    }

    override func hasSameDecoratedDetails(otherGameEvent: AbstractGameEvent) -> Bool {
        if let entityEvent = otherGameEvent as? EntityEventDecorator {
            if entityTypesAreContainedBy(entityEvent) {
                return true
            }
        }
        if let decoratedEvent = otherGameEvent as? GameEventBaseDecorator {
            return hasSameDecoratedDetails(otherGameEvent: decoratedEvent.wrappedEvent)
        }
        return false
    }

    override func toPersistable() -> PersistableAbstractGameEvent {
        let persistable = wrappedEvent.toPersistable()
        persistable.setEntityTypes(entityTypes)
        return persistable
    }
}
