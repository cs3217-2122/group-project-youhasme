//
//  GameEvent.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import Foundation

class GameEvent: AbstractGameEvent {
    var type: GameEventType

    init(type: GameEventType) {
        self.type = type
    }

    func isContainedBy(otherGameEvent: AbstractGameEvent) -> Bool {
        if otherGameEvent.type == type {
            return true
        } else if let decoratedEvent = otherGameEvent as? GameEventBaseDecorator {
            return self.isContainedBy(otherGameEvent: decoratedEvent.wrappedEvent)
        }
        return false
    }

    func containsGameEvent(otherGameEvent: AbstractGameEvent) -> Bool {
        otherGameEvent.isContainedBy(otherGameEvent: self)
    }

    func toPersistable() -> PersistableAbstractGameEvent {
        PersistableAbstractGameEvent(gameEventType: type)
    }
}
