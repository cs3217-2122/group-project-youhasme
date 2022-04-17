import Foundation

struct Entity {
    var entityType: EntityType
    var activeBehaviours: Set<Behaviour> = []
    init(entityType: EntityType) {
        self.entityType = entityType
    }

    func has(behaviour: Behaviour) -> Bool {
        activeBehaviours.contains(behaviour)
    }

    func isPlayer() -> Bool {
        for behaviour in activeBehaviours {
            switch behaviour {
            case .property(.player):
                return true
            default:
                continue
            }
        }
        return false
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
