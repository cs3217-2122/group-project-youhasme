//
//  SnakeLikeConnectorLockGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
final class SnakeLikeConnectorLockGeneratorDecorator: IdentityGeneratorDecorator {
    override func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = backingGenerator.generate(
            dimensions: dimensions,
            levelPosition: levelPosition,
            extremities: extremities
        )
        let blocks: [Classification] = [
            .noun(.door),
            .verb(.vIs),
            .property(.stop),
            .connective(.cIf),
            .conditionEvaluable(
                ConditionEvaluable(
                    evaluableType:
                            .level(id: levelPosition, evaluatingKeyPath: Level.getNamedKeyPath(given: .winCount)))
            ),
            .conditionRelation(.leq),
            .conditionEvaluable(ConditionEvaluable(evaluableType: .numericLiteral(0)))
        ]
        let startingCoord: Point
        if levelPosition.y.isEven {
            if levelPosition.x < extremities.rightSide - 1 {
                startingCoord = Point(x: 1, y: dimensions.bottomSide - 2)
            } else {
                startingCoord = Point(x: 1, y: 1)
            }
        } else {
            if levelPosition.x > 0 {
                startingCoord = Point(x: 1, y: dimensions.bottomSide - 2)
            } else {
                startingCoord = Point(x: 1, y: 1)
            }
        }
        var coord = startingCoord
        for i in 0..<blocks.count {
            tiles[coord].entities.append(Entity(
                entityType: EntityType(classification: blocks[i])
            ))
            coord = coord.translateX(dx: 1)
        }
        return tiles
    }
}
