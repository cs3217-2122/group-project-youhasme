//
//  PersistableLevelLayer.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
struct PersistableLevelLayer {
    var dimensions: Rectangle
    var tileMap: [Point: PersistableTile]
//    var tiles: [[PersistableTile]]
}

extension PersistableLevelLayer: Codable {}
