//
//  EntityIntent.swift
//  YouHasMe
//
//  Created by wayne on 29/3/22.
//

// Represents an intent to perform an entity action
struct EntityIntent: Hashable {
    var isRejected = false
    var action: EntityAction
}
