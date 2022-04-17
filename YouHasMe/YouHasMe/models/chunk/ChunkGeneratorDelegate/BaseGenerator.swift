//
//  BaseGenerator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 16/4/22.
//

import Foundation
class BaseGenerator: ChunkGeneratorDelegate {
    func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        getEmptyGrid(dimensions: dimensions)
    }
}
