//
//  ChunkGeneratorDelegate.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
protocol ChunkGeneratorDelegate {
    func generate(dimensions: Int) -> [[Tile]]
}

extension ChunkGeneratorDelegate {
    func getEmptyGrid(dimensions: Int) -> [[Tile]] {
        Array(
            repeatingFactory:
                Array(repeatingFactory: Tile(), count: dimensions),
            count: dimensions
        )
    }
}
