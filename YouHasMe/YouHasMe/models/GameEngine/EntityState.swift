//
//  EntityState.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Represents the state of an entity while it is being updated by the game engine
struct EntityState: Hashable {
    var entity: Entity
    var location: Location
    var intents: Set<EntityIntent> = []  // Actions that might be performed by this entity

    func has(behaviour: Behaviour) -> Bool {
        entity.has(behaviour: behaviour)
    }

    // Adds intent to perform action unconditionally
    mutating func add(action: EntityAction) {
        var intent = popIntent(action: action) ?? EntityIntent(action: action)
        intent.makeUnconditional()
        intents.insert(intent)
    }

    // Adds intent to perform action given condition
    mutating func add(action: EntityAction, ifEntityAt condLocation: Location, performs condAction: EntityAction) {
        let condition = EntityActionCondition(location: condLocation, action: condAction)
        if var intent = popIntent(action: action) { // Intent with action found
            intent.addCondition(condition)
            intents.insert(intent)
        } else {
            intents.insert(EntityIntent(action: action, condition: condition))
        }
    }

    // Returns next unrejected action to be performed or nil if there is no such action
    mutating func popAction() -> EntityAction? {
        let nextIntent = intents.first { !$0.isRejected }  // First unrejected intent
        guard let intent = nextIntent else {
            return nil  // No unrejected actions
        }
        intents.remove(intent)
        return intent.action
    }

    // Returns unrejected actions
    func getActions() -> [EntityAction] {
        intents.filter {
            !$0.isRejected
        }.map {
            $0.action
        }
    }

    // Rejects action if present in intents, does nothing otherwise
    mutating func reject(action: EntityAction) {
        guard var intent = popIntent(action: action) else {
            return  // No matching intent
        }
        intent.reject()
        intents.insert(intent)  // Insert new intent
    }

    func hasRejected(action: EntityAction) -> Bool {
        intents.contains {
            $0.action == action && $0.isRejected
        }
    }

    // Pops intent to perform specified action from intents, returns nil if there is no such intent
    private mutating func popIntent(action: EntityAction) -> EntityIntent? {
        let intent = intents.first { $0.action == action }
        if let intent = intent {
            intents.remove(intent)
        }
        return intent
    }
}
