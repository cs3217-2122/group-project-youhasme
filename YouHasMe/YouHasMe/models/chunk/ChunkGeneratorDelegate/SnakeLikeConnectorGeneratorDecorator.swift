//
//  SnakeLikeConnectorGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
final class SnakeLikeConnectorGeneratorDecorator: IdentityGeneratorDecorator {
    override func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = super.generate(
            dimensions: dimensions,
            levelPosition: levelPosition,
            extremities: extremities
        )
        let connectorEntity = Entity(entityType: EntityType(classification: .nounInstance(.door)))
        let midX = dimensions.width / 2
        let midY = dimensions.height / 2
        let topConnector = Point(x: midX, y: 0)
        let leftConnector = Point(x: 0, y: midY)
        let rightConnector = Point(x: dimensions.width - 1, y: midY)
        let bottomConnector = Point(x: midX, y: dimensions.height - 1)
        var deletionCoords: [Point] = []
        var creationCoords: [Point] = []
        if levelPosition.y.isEven {
            if levelPosition.x > 0 {
                deletionCoords.append(leftConnector)
            } else if levelPosition.y != 0 {
                deletionCoords.append(topConnector)
            }
        } else {
            if levelPosition.x < extremities.rightSide - 1 {
                deletionCoords.append(rightConnector)
            } else {
                deletionCoords.append(topConnector)
            }
        }

        if levelPosition.y.isEven {
            if levelPosition.x < extremities.rightSide - 1 {
                creationCoords.append(rightConnector)
            } else {
                creationCoords.append(bottomConnector)
            }
        } else {
            if levelPosition.x > 0 {
                creationCoords.append(leftConnector)
            } else if levelPosition.y < extremities.bottomSide - 1 {
                creationCoords.append(bottomConnector)
            }
        }

        for coord in deletionCoords {
            tiles[coord].entities.removeAll()
        }

        for coord in creationCoords {
            tiles[coord].entities.removeAll()
            tiles[coord].entities.append(connectorEntity)
        }
        return tiles
    }
}
