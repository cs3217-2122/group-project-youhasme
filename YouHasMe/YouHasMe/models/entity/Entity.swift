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
}

extension Entity: Codable, Hashable {
}
