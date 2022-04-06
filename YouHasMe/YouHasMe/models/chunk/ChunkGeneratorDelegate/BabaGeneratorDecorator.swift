//
//  BabaGenerator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
final class BabaGeneratorDecorator: ChunkGeneratorDecorator {
    var backingGenerator: AnyChunkGeneratorDelegate
    init<T>(generator: T) where T: ChunkGeneratorDelegate {
        backingGenerator = generator.eraseToAnyGenerator()
    }

    func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = backingGenerator.generate(
            dimensions: dimensions, levelPosition: levelPosition, extremities: extremities
        )

        let blocks: [Classification] = [
            .noun(.baba),
            .verb(.vIs),
            .property(.you)
        ]
        // randomly choose a coord with three adjacent blank spaces
        let iterationLimit = 100
        var startingCoord: Point?
        for _ in 0..<iterationLimit {
            let randomPoint = Point(
                x: Int.random(in: 0..<dimensions.width),
                y: Int.random(in: 0..<dimensions.height)
            )

            let points = [
                randomPoint,
                randomPoint.translateX(dx: 1),
                randomPoint.translateX(dx: 2)
            ]
            if points.allSatisfy({ dimensions.isWithinBounds($0) && tiles[$0].entities.isEmpty }) {
                startingCoord = randomPoint
                break
            }
        }

        if var coord = startingCoord {
            for i in 0..<blocks.count {
                tiles[coord].entities.append(Entity(
                    entityType: EntityType(classification: blocks[i])
                ))
                coord = coord.translateX(dx: 1)
            }
        }

        for _ in 0..<iterationLimit {
            let randomPoint = Point(
                x: Int.random(in: 0..<dimensions.width),
                y: Int.random(in: 0..<dimensions.height)
            )

            if tiles[randomPoint].entities.isEmpty {
                tiles[randomPoint].entities.append(
                    Entity(entityType: EntityType(classification: .nounInstance(.baba)))
                )
                break
            }
        }

        return tiles
    }
}
