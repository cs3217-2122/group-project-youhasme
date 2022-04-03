import Foundation

struct Entity {
    var entityType: EntityType
    var activeBehaviours: [Behaviour] = []
    init(entityType: EntityType) {
        self.entityType = entityType
    }

    func has(behaviour: Behaviour) -> Bool {
        activeBehaviours.contains(behaviour)
    }

    mutating func addBehaviour(behaviour: Behaviour) {
        activeBehaviours.append(behaviour)
    }

    mutating func removeBehaviour(behaviour: Behaviour) {
        self.activeBehaviours = activeBehaviours.filter { $0 != behaviour }
    }
}

extension Entity: Codable {}
extension Entity: Hashable {}
