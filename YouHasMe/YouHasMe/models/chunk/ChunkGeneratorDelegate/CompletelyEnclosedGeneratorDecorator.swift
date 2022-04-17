//
//  CompletelyEnclosedGenerator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
final class CompletelyEnclosedGeneratorDecorator: IdentityGeneratorDecorator {
    private func withSurroundingWalls(dimensions: Rectangle, tiles: [[Tile]]) -> [[Tile]] {
        var tiles = tiles
        let bedrockEntity = Entity(entityType: EntityType(classification: .nounInstance(.rock)))
        for y in 0..<dimensions.height {
            tiles[y][0].entities.append(
                bedrockEntity
            )
            tiles[y][dimensions.width - 1].entities.append(
                bedrockEntity
            )
        }

        for x in 1..<(dimensions.width - 1) {
            tiles[0][x].entities.append(
                bedrockEntity
            )
            tiles[dimensions.height - 1][x].entities.append(
                bedrockEntity
            )
        }

        return tiles
    }

    override func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = super.generate(
            dimensions: dimensions,
            levelPosition: levelPosition,
            extremities: extremities
        )
        tiles = withSurroundingWalls(dimensions: dimensions, tiles: tiles)
        return tiles
    }
}
