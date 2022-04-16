//
//  LevelEventDecorator.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 3/4/22.
//

import Foundation

class LevelEventDecorator: GameEventBaseDecorator {
    var levelId: Point

    init(wrappedEvent: AbstractGameEvent, levelId: Point) {
        self.levelId = levelId
        super.init(wrappedEvent: wrappedEvent)
    }

    func hasSameLevel(_ otherLevelEvent: LevelEventDecorator) -> Bool {
        levelId == otherLevelEvent.levelId
    }

    override func hasSameDecoratedDetails(otherGameEvent: AbstractGameEvent) -> Bool {
        if let levelEvent = otherGameEvent as? LevelEventDecorator {
            if hasSameLevel(levelEvent) {
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
        persistable.setLevelId(levelId)
        return persistable
    }
}
