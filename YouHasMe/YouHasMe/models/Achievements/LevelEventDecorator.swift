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

    override func hasLevel(levelName: String) -> Bool {
        self.levelName == levelName || wrappedEvent.hasLevel(levelName: levelName)
    }

    override func containsGameEvent(event: AbstractGameEvent) -> Bool {
        event.isContainedBy(gameEvent: self)
    }

    override func isContainedBy(gameEvent: AbstractGameEvent) -> Bool {
        gameEvent.hasLevel(levelName: levelName)
    }

    override func toPersistable() -> PersistableAbstractGameEvent {
        let persistable = wrappedEvent.toPersistable()
        persistable.setLevelName(levelName)
        return persistable
    }
}
