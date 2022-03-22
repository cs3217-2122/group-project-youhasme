//
//  PersistableChunk.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct PersistableChunkNode {
    var identifier: Point
    var chunkTiles: [[PersistableMetaTile]]
}

extension PersistableChunkNode: Codable {}
