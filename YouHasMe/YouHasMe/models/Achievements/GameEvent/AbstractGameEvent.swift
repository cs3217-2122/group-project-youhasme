//
//  AbstractGameEvent.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 3/4/22.
//

import Foundation

protocol AbstractGameEvent {
    var type: GameEventType { get }

    func containsGameEvent(otherGameEvent: AbstractGameEvent) -> Bool
    func isContainedBy(otherGameEvent: AbstractGameEvent) -> Bool
    func toPersistable() -> PersistableAbstractGameEvent
}

enum GameEventType: Int, Codable {
    case move
    case win
    case designLevel
    case movingAcrossLevel
}
