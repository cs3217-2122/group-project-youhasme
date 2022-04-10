//
//  BabaGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 7/4/22.
//

import Foundation
final class BabaIsYouGeneratorDecorator: ChunkGeneratorDecorator {
    var backingGenerator: AnyChunkGeneratorDelegate
    var nounIsPropertyGenerator = NounIsPropertyRuleGenerator(
        noun: .baba, property: .you, shouldGenerateNounInstance: true
    )
    init<T>(generator: T) where T: ChunkGeneratorDelegate {
        backingGenerator = generator.eraseToAnyGenerator()
    }

    func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = backingGenerator.generate(
            dimensions: dimensions, levelPosition: levelPosition, extremities: extremities
        )

        tiles = nounIsPropertyGenerator.generate(
            dimensions: dimensions, levelPosition: levelPosition, extremities: extremities, tiles: tiles
        )

        return tiles
    }
}