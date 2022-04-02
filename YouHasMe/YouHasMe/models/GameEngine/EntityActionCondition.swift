//
//  EntityActionCondition.swift
//  YouHasMe
//
//  Created by wayne on 2/4/22.
//

// Represents a condition requiring entity at specified location perform the specified action
struct EntityActionCondition: Hashable {
    var location: Location
    var action: EntityAction

    func isFulfilled(by state: LevelLayerState) -> Bool {
        state.entityStates.filter {
            $0.location == location
        }.allSatisfy {
            $0.getActions().contains(action)
        }
    }
}
