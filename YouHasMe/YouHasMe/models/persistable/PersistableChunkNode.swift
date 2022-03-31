//
//  PersistableChunk.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct PersistableChunkNode {
    var identifier: Point
//    var chunkTiles: [[PersistableMetaTile]]
    var map : [Point: PersistableMetaTile]
    
    init(identifier: Point, chunkTiles: [[PersistableMetaTile]]) {
        self.identifier = identifier
        var map : [Point: PersistableMetaTile] = [:]
        for x in 0..<chunkTiles.count {
            for y in 0..<chunkTiles[0].count {
                let point = Point(x: x, y: y)
                map[point] = chunkTiles[y][x]
            }
        }
        self.map = map
    }
}

extension PersistableChunkNode: Codable {}
