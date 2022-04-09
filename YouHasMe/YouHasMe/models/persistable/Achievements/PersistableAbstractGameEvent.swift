//
//  PersistableAbstractGameEvent.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 4/4/22.
//

import Foundation

class PersistableAbstractGameEvent: Codable {
    var levelName: String?
    var entityType: PersistableEntityType?
    var gameEventType: GameEventType

    init(gameEventType: GameEventType, levelName: String? = nil, entityType: EntityType? = nil) {
        self.levelName = levelName
        self.entityType = entityType?.toPersistable()
        self.gameEventType = gameEventType
    }

    func setLevelName(_ levelName: String) {
        self.levelName = levelName
    }

    func setEntityType(_ entityType: EntityType) {
        self.entityType = entityType.toPersistable()
    }

    func toAbstractGameEvent() -> AbstractGameEvent {
        var gameEvent: AbstractGameEvent = GameEvent(type: gameEventType)
        if let levelName = levelName {
            gameEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelName: levelName)
        }
        if let entityType = entityType {
            gameEvent = EntityEventDecorator(
                wrappedEvent: gameEvent,
                entityType: EntityType.fromPersistable(entityType)
            )
        }
        return gameEvent
    }
}
