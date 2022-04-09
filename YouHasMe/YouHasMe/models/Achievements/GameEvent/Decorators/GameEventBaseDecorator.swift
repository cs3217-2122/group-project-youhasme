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

    func hasSameDecoratedDetails(otherGameEvent: AbstractGameEvent) -> Bool {
        assert(false, "should be implemented by children decorators")
        return false
    }

    func isContainedBy(otherGameEvent: AbstractGameEvent) -> Bool {
        if !hasSameDecoratedDetails(otherGameEvent: otherGameEvent) {
            return false
        }
        return wrappedEvent.isContainedBy(otherGameEvent: otherGameEvent)
    }

    func containsGameEvent(otherGameEvent: AbstractGameEvent) -> Bool {
        otherGameEvent.isContainedBy(otherGameEvent: self)
    }

    func toPersistable() -> PersistableAbstractGameEvent {
        assert(false, "should be implemented by children decorators")
        return wrappedEvent.toPersistable()
    }
}
