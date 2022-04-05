//
//  PersistableDungeon.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct PersistableDungeon {
    var name: String
    var entryChunkPosition: Point
    var dimensions: Rectangle
}

extension PersistableDungeon: Codable {}
