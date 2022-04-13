//
//  PersistableEntity.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
struct PersistableEntity {
    var entityType: PersistableEntityType
}

extension PersistableEntity: Codable {}
