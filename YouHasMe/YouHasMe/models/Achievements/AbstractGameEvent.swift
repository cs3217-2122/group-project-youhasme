//
//  AbstractGameEvent.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 3/4/22.
//

import Foundation

protocol AbstractGameEvent {
    var type: GameEventType { get }

    func hasEntity(entityType: EntityType) -> Bool
    func hasEvent(eventType: GameEventType) -> Bool
    func hasLevel(levelName: String) -> Bool
    func containsGameEvent(event: AbstractGameEvent) -> Bool
    func isContainedBy(gameEvent: AbstractGameEvent) -> Bool
    func toPersistable() -> PersistableAbstractGameEvent
}

enum GameEventType: Int, Codable {
    case move
    case win
    case designLevel
}

extension AbstractGameEvent {
    func hasEntity(entityType: EntityType) -> Bool {
        false
    }

    func hasEvent(eventType: GameEventType) -> Bool {
        false
    }

    func hasLevel(levelName: String) -> Bool {
        false
    }
}

class PersistableAbstractGameEvent: Codable {
    var levelName: String?
    var entityType: EntityType?
    var gameEventType: GameEventType

    init(gameEventType: GameEventType, levelName: String? = nil, entityType: EntityType? = nil) {
        self.levelName = levelName
        self.entityType = entityType
        self.gameEventType = gameEventType
    }

    func setLevelName(_ levelName: String) {
        self.levelName = levelName
    }

    func setEntityType(_ entityType: EntityType) {
        self.entityType = entityType
    }

    func toAbstractGameEvent() -> AbstractGameEvent {
        var gameEvent: AbstractGameEvent = GameEvent(type: gameEventType)
        if let levelName = levelName {
            gameEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelName: levelName)
        }
        if let entityType = entityType {
            gameEvent = EntityEventDecorator(wrappedEvent: gameEvent, entityType: entityType)
        }
        return gameEvent
    }
}
