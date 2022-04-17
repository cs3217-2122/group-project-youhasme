//
//  QuadDirectionalGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 16/4/22.
//

import Foundation

final class QuadDirectionalGeneratorDecorator: IdentityGeneratorDecorator {
    override func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = super.generate(
            dimensions: dimensions,
            levelPosition: levelPosition,
            extremities: extremities
        )
        let connectorEntity = Entity(
            entityType: EntityType(classification: .nounInstance(.door))
        )
        let midX = dimensions.width / 2
        let midY = dimensions.height / 2
        let topConnector = Point(x: midX, y: 0)
        let leftConnector = Point(x: 0, y: midY)
        let rightConnector = Point(x: dimensions.width - 1, y: midY)
        let bottomConnector = Point(x: midX, y: dimensions.height - 1)

        var creationCoords: [Point] = [
            topConnector, leftConnector, rightConnector, bottomConnector
        ]

        if levelPosition.x == 0 {
            creationCoords.removeAll(leftConnector)
        }

        if levelPosition.y == 0 {
            creationCoords.removeAll(topConnector)
        }

        if levelPosition.x == extremities.width - 1 {
            creationCoords.removeAll(rightConnector)
        }

        if levelPosition.y == extremities.height - 1 {
            creationCoords.removeAll(bottomConnector)
        }

        for coord in creationCoords {
            tiles[coord].entities.removeAll()
            tiles[coord].entities.append(connectorEntity)
        }

        return tiles
    }
}
