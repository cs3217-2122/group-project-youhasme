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

    func hasEvent(eventType: GameEventType) -> Bool {
        type == eventType
    }

    func isContainedBy(gameEvent: AbstractGameEvent) -> Bool {
        gameEvent.hasEvent(eventType: type)
    }

    func containsGameEvent(event: AbstractGameEvent) -> Bool {
        event.isContainedBy(gameEvent: self)
    }

    func toPersistable() -> PersistableAbstractGameEvent {
        PersistableAbstractGameEvent(gameEventType: type)
    }
}
