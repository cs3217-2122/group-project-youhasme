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
