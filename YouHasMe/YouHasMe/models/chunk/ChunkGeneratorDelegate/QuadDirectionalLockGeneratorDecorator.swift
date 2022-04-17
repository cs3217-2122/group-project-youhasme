//
//  QuadDirectionalLockGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 16/4/22.
//

import Foundation

final class QuadDirectionalLockGeneratorDecorator: IdentityGeneratorDecorator {
    override func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = super.generate(
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

        var coord = Point(x: 0, y: 1)
        tiles[coord].entities.removeAll()
        for i in 0..<blocks.count {
            tiles[coord].entities.append(Entity(
                entityType: EntityType(classification: blocks[i])
            ))
            coord = coord.translateX(dx: 1)
        }
        return tiles
    }
}
