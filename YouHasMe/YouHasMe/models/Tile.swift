//
//  Tile.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
struct Tile {
    var entities: [Entity] = []
}

extension Tile: Hashable {}

extension Tile {
    func toPersistable() -> PersistableTile {
        PersistableTile(entities: entities.map { $0.toPersistable() })
    }

    static func fromPersistable(_ persistableTile: PersistableTile) -> Tile {
        Tile(entities: persistableTile.entities.map { Entity.fromPersistable($0) })
    }
}
