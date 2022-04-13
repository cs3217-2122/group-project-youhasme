//
//  ChunkGeneratorDelegate.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
protocol ChunkGeneratorDelegate: AnyObject {
    func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]]
}

extension ChunkGeneratorDelegate {
    func getEmptyGrid(dimensions: Rectangle) -> [[Tile]] {
        Array(
            repeatingFactory:
                Array(repeatingFactory: Tile(), count: dimensions.width),
            count: dimensions.height
        )
    }

    func decorateWith<T: ChunkGeneratorDecorator>(_ decoratorClass: T.Type) -> AnyChunkGeneratorDelegate {
        decoratorClass.init(generator: self).eraseToAnyGenerator()
    }

    func eraseToAnyGenerator() -> AnyChunkGeneratorDelegate {
        AnyChunkGeneratorDelegate(generator: self)
    }
}

class AnyChunkGeneratorDelegate: ChunkGeneratorDelegate {
    private let _generate: (Rectangle, Point, Rectangle) -> [[Tile]]

    init<T: ChunkGeneratorDelegate>(generator: T) {
        _generate = generator.generate(dimensions:levelPosition:extremities:)
    }

    func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        _generate(dimensions, levelPosition, extremities)
    }
}

protocol ChunkGeneratorDecorator: ChunkGeneratorDelegate {
    var backingGenerator: AnyChunkGeneratorDelegate { get }
    init<T: ChunkGeneratorDelegate>(generator: T)
}
