//
//  PersistableTile.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct PersistableTile {
    var entities: [PersistableEntity] = []
}

extension PersistableTile: Codable {}
