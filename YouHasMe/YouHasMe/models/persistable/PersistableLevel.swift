//
//  PersistableLevel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct PersistableLevel {
    var id: Point
    var name: String
    var dimensions: Rectangle
    var layer: PersistableLevelLayer
}

extension PersistableLevel: Codable {}
