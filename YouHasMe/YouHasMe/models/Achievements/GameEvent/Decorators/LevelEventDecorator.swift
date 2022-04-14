//
//  LevelEventDecorator.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 3/4/22.
//

import Foundation

class LevelEventDecorator: GameEventBaseDecorator {
    var levelName: String

    init(wrappedEvent: AbstractGameEvent, levelName: String) {
        self.levelName = levelName
        super.init(wrappedEvent: wrappedEvent)
    }

    func hasSameLevel(_ otherLevelEvent: LevelEventDecorator) -> Bool {
        levelName == otherLevelEvent.levelName
    }

    override func hasSameDecoratedDetails(otherGameEvent: AbstractGameEvent) -> Bool {
        levelNameIsContainedBy(otherGameEvent: otherGameEvent)
    }

    func levelNameIsContainedBy(otherGameEvent: AbstractGameEvent) -> Bool {
        if let levelEvent = otherGameEvent as? LevelEventDecorator {
            if hasSameLevel(levelEvent) {
                return true
            }
        }
        if let decoratedEvent = otherGameEvent as? GameEventBaseDecorator {
            return levelNameIsContainedBy(otherGameEvent: decoratedEvent.wrappedEvent)
        }
        return false
    }

    override func toPersistable() -> PersistableAbstractGameEvent {
        let persistable = wrappedEvent.toPersistable()
        persistable.setLevelName(levelName)
        return persistable
    }
}
