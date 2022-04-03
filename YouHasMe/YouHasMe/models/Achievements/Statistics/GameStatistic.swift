//
//  NumericStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 31/3/22.
//

import Foundation

class GameStatistic: Codable, Hashable {
    enum StatisticType: Int, Codable {
        case level
        case lifetime
    }

    var name: String
    var value: Int
    var type: StatisticType
    var entity: EntityType?
    var gameEvent: GameEventType?
    var levelId: String?

    init(value: Int, statisticType: StatisticType, entity: EntityType? = nil,
         gameEvent: GameEventType, levelId: String? = nil) {
        self.name = GameStatistic.getNameFromProperties(statisticType: statisticType, entity: entity,
                                          gameEvent: gameEvent, levelId: levelId)
        self.value = value
        self.type = statisticType
        self.entity = entity
        self.gameEvent = gameEvent
        self.levelId = levelId
    }

    func increase() {
        value += 1
        globalLogger.info("\(name) increased to \(value)")
    }

    func reset() {
        value = 0
    }

    static func getNameFromProperties(statisticType: StatisticType, entity: EntityType? = nil,
                                     gameEvent: GameEventType, levelId: String? = nil) -> String {
        var name = ""

        name += getStatisticTypeName(statisticType: statisticType)
        name += getGameEventName(gameEvent: gameEvent)
        name += getEntityName(entity: entity)
        name += getLevelName(levelId: levelId)

        return name
    }

    static func getStatisticTypeName(statisticType: StatisticType) -> String {
        switch statisticType {
        case .level:
            return "Level"
        case .lifetime:
            return "Lifetime"
        }
    }

    static func getLevelName(levelId: String?) -> String {
        guard let levelId = levelId else {
            return ""
        }

        return " for \(levelId)"
    }

    static func getGameEventName(gameEvent: GameEventType) -> String {
        switch gameEvent {
        case .designLevel:
            return " Level Designs"
        case .move:
            return " Moves"
        case .win:
            return " Wins"
        }
    }
    static func getEntityName(entity: EntityType?) -> String {
        guard let entity = entity else {
            return ""
        }

        // todo: change so all entity types can be mapped to string
        return " by \(entityTypeToImageString(type: entity))"
    }
    static func == (lhs: GameStatistic, rhs: GameStatistic) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    func handleGameEvent(event: AbstractGameEvent) {
        if !hasValidEntity(event: event) {
            return
        }
        if !hasValidEvent(event: event) {
            return
        }
        if !hasValidLevel(event: event) {
            return
        }
        increase()
    }

    func hasValidEntity(event: AbstractGameEvent) -> Bool {
        guard let entity = entity else {
            return true
        }
        return event.hasEntity(entityType: entity)
    }

    func hasValidEvent(event: AbstractGameEvent) -> Bool {
        guard let gameEvent = gameEvent else {
            return true
        }
        return event.hasEvent(eventType: gameEvent)
    }

    func hasValidLevel(event: AbstractGameEvent) -> Bool {
        guard let levelId = levelId else {
            return true
        }
        return event.hasLevel(levelName: levelId)
    }
}
