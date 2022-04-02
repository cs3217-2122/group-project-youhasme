//
//  GameEvent.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import Foundation

class GameEvent: AbstractGameEvent {
    var type: GameEventType

    init(type: GameEventType) {
        self.type = type
    }

    func hasEvent(eventType: GameEventType) -> Bool {
        type == eventType
    }
}
