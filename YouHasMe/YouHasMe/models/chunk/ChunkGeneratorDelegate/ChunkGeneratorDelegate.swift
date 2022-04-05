//
//  ChunkGeneratorDelegate.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
protocol ChunkGeneratorDelegate {
    func generate(chunkDimensions: Int) -> [[Tile]]
}

extension ChunkGeneratorDelegate {
    func getEmptyGrid(chunkDimensions: Int = ChunkNode.chunkDimensions) -> [[Tile]] {
        Array(
            repeatingFactory:
                Array(repeatingFactory: Tile(), count: chunkDimensions),
            count: chunkDimensions
        )
    }
}
