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

    // Represents the conditions that give rise to an intent (something might cause this action to happen)
    // For example, previous block being pushed is a condition for next block to be moved as a result
    // Any of the conditions being true is sufficient for action to be taken (assuming it is not rejected)
    // An empty set means that no condition is required
    private(set) var conditions: Set<EntityActionCondition> = []

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
    mutating func makeUnconditional() {
        conditions = []
    }

    // Adds a possible condition that will give rise to this intent
    mutating func addCondition(_ condition: EntityActionCondition) {
        guard isConditional() else {
            return  // If intent is already unconditional, no point adding a condition
        }
        conditions.insert(condition)
    }

    mutating func reject() {
        isRejected = true
    }

    // Returns true if conditions has been met by state (or no conditions required)
    func conditionsMet(by state: LevelLayerState) -> Bool {
        !isConditional() || conditions.contains { $0.isFulfilled(by: state) }
    }

    // Returns whether intent requires conditions to be met
    func isConditional() -> Bool {
        !conditions.isEmpty
    }

}
