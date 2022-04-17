//
//  PersistableAbstractGameEvent.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 4/4/22.
//

import Foundation

class PersistableAbstractGameEvent: Codable {
    var levelId: Point?
    var dungeonId: String?
    var entityTypes: [PersistableEntityType]
    var gameEventType: GameEventType

    init(gameEventType: GameEventType, levelId: Point? = nil, entityTypes: Set<EntityType> = [],
         dungeonId: String? = nil) {
        self.gameEventType = gameEventType
        self.levelId = levelId
        self.entityTypes = entityTypes.map { $0.toPersistable() }
        self.dungeonId = dungeonId
    }

    func setLevelId(_ levelId: Point) {
        self.levelId = levelId
    }

    func setEntityTypes(_ entityTypes: Set<EntityType>) {
        self.entityTypes = entityTypes.map { $0.toPersistable() }
    }

    func setDungeonId(_ dungeonId: String) {
        self.dungeonId = dungeonId
    }

    func toAbstractGameEvent() -> AbstractGameEvent {
        var gameEvent: AbstractGameEvent = GameEvent(type: gameEventType)
        gameEvent = getDecoratedEvent(gameEvent: gameEvent)
        return gameEvent
    }

    private func getDecoratedEvent(gameEvent: AbstractGameEvent) -> AbstractGameEvent {
        var decoratedGameEvent = gameEvent
        decoratedGameEvent = getLevelDecoratedEvent(gameEvent: decoratedGameEvent)
        decoratedGameEvent = getEntityDecoratedEvent(gameEvent: decoratedGameEvent)
        decoratedGameEvent = getDungeonDecoratedEvent(gameEvent: decoratedGameEvent)
        return decoratedGameEvent
    }

    private func getLevelDecoratedEvent(gameEvent: AbstractGameEvent) -> AbstractGameEvent {
        if let levelId = levelId {
            return LevelEventDecorator(wrappedEvent: gameEvent, levelId: levelId)
        }
        return gameEvent
    }

    private func getEntityDecoratedEvent(gameEvent: AbstractGameEvent) -> AbstractGameEvent {
        if !entityTypes.isEmpty {
            return EntityEventDecorator(
                wrappedEvent: gameEvent,
                entityTypes: Set(entityTypes.map { EntityType.fromPersistable($0) })
            )
        }
        return gameEvent
    }

    private func getDungeonDecoratedEvent(gameEvent: AbstractGameEvent) -> AbstractGameEvent {
        if let dungeonId = dungeonId {
            return DungeonEventDecorator(wrappedEvent: gameEvent, dungeonId: dungeonId)
        }
        return gameEvent
    }
}
