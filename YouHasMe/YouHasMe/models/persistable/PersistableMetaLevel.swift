//
//  PersistableMetaLevel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct PersistableMetaLevel {
    var name: String
    var entryChunkPosition: Point
    var dimensions: PositionedRectangle
}

extension PersistableMetaLevel: Codable {}
