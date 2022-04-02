//
//  EntityIntent.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Represents an intent to perform an entity action
struct EntityIntent: Hashable {
    private(set) var isRejected = false  // A rejected intent is never acted upon
    private(set) var action: EntityAction

    // Represents the conditions that give rise to an intent
    // Any of the conditions being true is sufficient for action to be taken (assuming it is not rejected)
    // An empty set means that no condition is required
    private(set) var conditions: Set<EntityActionCondition?> = []

    // Unconditional intent
    init(action: EntityAction) {
        self.action = action
    }

    // Conditional intent
    init(action: EntityAction, condition: EntityActionCondition) {
        self.action = action
        conditions = [condition]
    }

    // Removes all conditions
    mutating func removeAllConditions() {
        conditions = []
    }

    mutating func reject() {
        isRejected = true
    }

}
