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

    // Adds intent to perform action if not already present
    mutating func add(action: EntityAction) {
        guard intents.allSatisfy({ $0.action != action }) else {
            return  // Intent already added
        }
        intents.insert(EntityIntent(action: action))
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
        let newIntents: [EntityIntent] = intents.map {
            var intent = $0
            if intent.action == action {
                intent.isRejected = true
            }
            return intent
        }
        intents = Set(newIntents)
    }

    func hasRejected(action: EntityAction) -> Bool {
        intents.contains {
            $0.action == action && $0.isRejected
        }
    }
}
