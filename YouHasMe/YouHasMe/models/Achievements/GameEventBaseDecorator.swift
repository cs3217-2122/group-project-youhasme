//
//  GameEventBaseDecorator.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 3/4/22.
//

import Foundation

class GameEventBaseDecorator: AbstractGameEvent {
    private(set) var wrappedEvent: AbstractGameEvent
    var type: GameEventType {
        wrappedEvent.type
    }

    init(wrappedEvent: AbstractGameEvent) {
        self.wrappedEvent = wrappedEvent
    }

    func hasEntity(entityType: EntityType) -> Bool {
        wrappedEvent.hasEntity(entityType: entityType)
    }

    func hasEvent(eventType: GameEventType) -> Bool {
        wrappedEvent.hasEvent(eventType: eventType)
    }

    func hasLevel(levelName: String) -> Bool {
        wrappedEvent.hasLevel(levelName: levelName)
    }

    func isContainedBy(gameEvent: AbstractGameEvent) -> Bool {
        type == gameEvent.type && wrappedEvent.isContainedBy(gameEvent: gameEvent)
    }

    func containsGameEvent(event: AbstractGameEvent) -> Bool {
        event.isContainedBy(gameEvent: self) || event.isContainedBy(gameEvent: wrappedEvent)
    }

    func toPersistable() -> PersistableAbstractGameEvent {
        assert(false, "should be implemented by children decorators")
        return wrappedEvent.toPersistable()
    }
}
