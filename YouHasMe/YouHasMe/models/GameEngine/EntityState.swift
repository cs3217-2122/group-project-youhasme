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
    var intents: Set<EntityIntent> = []

    func has(behaviour: Behaviour) -> Bool {
        entity.has(behaviour: behaviour)
    }

    // Adds intent to perform action unconditionally
    mutating func add(action: EntityAction) {
        let oldIntent = intents.first { $0.action == action }  // Search for intent with matching action
        if var intent = oldIntent {  // Action already present
            intents.remove(intent)  // Remove old intent
            intent.removeAllConditions()  // Remove conditions from entent
            intents.insert(intent)  // Insert new intent
        } else {  // No intent with action yet
            intents.insert(EntityIntent(action: action))
        }
    }

    // Adds intent to perform action given condition
    mutating func add(action: EntityAction, ifEntityAt condLocation: Location, performs condAction: EntityAction) {
        let condition = EntityActionCondition(location: condLocation, action: condAction)
        let oldIntent = intents.first { $0.action == action }  // Search for intent with matching action
        if var intent = oldIntent {  // Action already present
            intents.remove(intent)  // Remove old intent
            intent.addCondition(condition)
            intents.insert(intent)  // Insert new intent
        } else {  // No intent with action yet
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
        let oldIntent = intents.first { $0.action == action }  // Search for intent with matching action
        guard var intent = oldIntent else {
            return  // No matching intent
        }
        intents.remove(intent)  // Remove old intent
        intent.reject()
        intents.insert(intent)  // Insert new intent
    }

    func hasRejected(action: EntityAction) -> Bool {
        intents.contains {
            $0.action == action && $0.isRejected
        }
    }
}
