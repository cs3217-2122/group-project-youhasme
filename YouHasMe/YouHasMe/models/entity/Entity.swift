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

extension Entity {
    func toPersistable() -> PersistableEntity {
        PersistableEntity(entityType: entityType.toPersistable())
    }

    static func fromPersistable(_ persistableEntity: PersistableEntity) -> Entity {
        Entity(entityType: EntityType.fromPersistable(persistableEntity.entityType))
    }
}

extension Entity: Hashable {}
