//
//  PersistableDungeon.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct PersistableDungeon {
    var name: String
    var dimensions: Rectangle
    var levelDimensions: Rectangle
    var entryLevelPosition: Point
    var levelNameToPositionMap: [String: Point] = [:]
}

extension PersistableDungeon: Codable {}
