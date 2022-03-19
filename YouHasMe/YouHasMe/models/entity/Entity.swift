import Foundation

struct Entity {
    var entityType: EntityType
    var activeBehaviours: [Behaviour] = []
    init(entityType: EntityType) {
        self.entityType = entityType
    }
}
