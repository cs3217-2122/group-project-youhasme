//
//  BaseGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 16/4/22.
//

import Foundation

class IdentityGeneratorDecorator: ChunkGeneratorDecorator {
    var backingGenerator: AnyChunkGeneratorDelegate
    required init<T>(generator: T) where T : ChunkGeneratorDelegate {
        backingGenerator = generator.eraseToAnyGenerator()
    }
    
    func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        backingGenerator.generate(dimensions: dimensions, levelPosition: levelPosition, extremities: extremities)
    }
}
