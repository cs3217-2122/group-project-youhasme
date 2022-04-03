//
//  ChunkGeneratorDelegate.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
protocol ChunkGeneratorDelegate {
    func generate(chunkDimensions: Int) -> [[MetaTile]]
}

extension ChunkGeneratorDelegate {
    func getEmptyGrid(chunkDimensions: Int = ChunkNode.chunkDimensions) -> [[MetaTile]] {
        Array(
            repeatingFactory:
                Array(repeatingFactory: MetaTile(), count: chunkDimensions),
            count: chunkDimensions
        )
    }
}
