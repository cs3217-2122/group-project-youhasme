//
//  ConnectorGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
final class ConnectorGeneratorDecorator: IdentityGeneratorDecorator {
    override func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = super.generate(
            dimensions: dimensions,
            levelPosition: levelPosition,
            extremities: extremities
        )
        let connectorEntity = Entity(entityType: EntityType(classification: .nounInstance(.door)))
        let midX = dimensions.width / 2
        let midY = dimensions.height / 2
        let coords = [
            Point(x: midY, y: 0),
            Point(x: midY, y: dimensions.width - 1),
            Point(x: 0, y: midX),
            Point(x: dimensions.height - 1, y: midX)
        ]
        for coord in coords {
            tiles[coord].entities.removeAll()
            tiles[coord].entities.append(connectorEntity)
        }
        return tiles
    }
}
