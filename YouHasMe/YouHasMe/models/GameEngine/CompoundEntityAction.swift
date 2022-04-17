//
//  CompoundEntityAction.swift
//  YouHasMe
//
//  Created by wayne on 17/4/22.
//

// Represents the effect of multiple EntityActions
struct CompoundEntityAction {
    var dx = 0
    var dy = 0
    var transformTarget: Noun?
    var isDestroy = false

    init(actions: [EntityAction]) {
        for action in actions {
            switch action {
            case let .move(dx, dy):
                self.dx += dx
                self.dy += dy
            case let .transform(target):
                transformTarget = target
            case .destroy:
                isDestroy = true
            }
        }
    }

    // Applies compound action to entity and returns resulting entities
    func apply(state: EntityState) -> [EntityState] {
        var newState = state
        newState.location.x += dx
        newState.location.y += dy
        if isDestroy {
            return []
        }
        if let target = transformTarget {  // Handle transform
            newState.entity.entityType = EntityType(classification: .nounInstance(target))
        }
        return [newState]
    }
}
