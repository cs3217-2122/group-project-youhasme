//
//  DungeonEventDecorator.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 15/4/22.
//

import Foundation

class DungeonEventDecorator: GameEventBaseDecorator {
    var dungeonId: String

    init(wrappedEvent: AbstractGameEvent, dungeonId: String) {
        self.dungeonId = dungeonId
        super.init(wrappedEvent: wrappedEvent)
    }

    func hasSameDungeon(_ otherDungeonEvent: DungeonEventDecorator) -> Bool {
        dungeonId == otherDungeonEvent.dungeonId
    }

    override func hasSameDecoratedDetails(otherGameEvent: AbstractGameEvent) -> Bool {
        if let dungeonEvent = otherGameEvent as? DungeonEventDecorator {
            if hasSameDungeon(dungeonEvent) {
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
        persistable.setDungeonId(dungeonId)
        return persistable
    }
}
