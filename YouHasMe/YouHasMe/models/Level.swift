//
//  Level.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import Foundation

class Rectangle {
    var width: Int
    var height: Int
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

class Level {
    var layers: BidirectionalArray<LevelLayer>
    var dimensions: Rectangle
    init(dimensions: Rectangle) {
        layers = BidirectionalArray()
        self.dimensions = dimensions
    }
}

extension Level: LevelLayerDelegate {}

protocol OutletDelegate: AnyObject {
    var dimensions: Rectangle { get }
}

enum RectangleEdge {
    case topEdge
    case bottomEdge
    case leftEdge
    case rightEdge
}

class Outlet {
    var connector: Connector?
    // outlet lies on the boundaries
    var edge: RectangleEdge
    var position: ClosedRange<Int>
    init(edge: RectangleEdge, position: ClosedRange<Int>) {
        self.edge = edge
        self.position = position
    }
}

protocol LevelLayerDelegate: AnyObject {
    var dimensions: Rectangle { get }
}

class LevelLayer {
    weak var delegate: LevelLayerDelegate?
    var outlets: [Outlet] = []
    var tiles: [Tile] = []
    func getTileAt(x: Int, y: Int) -> Tile {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return tiles[x + y * delegate.dimensions.width]
    }
    
    // To be generalized, each cell could have more than one entity
    func getAbstractRepresentation() -> EntityBlock {
        guard let delegate = delegate else {
            fatalError()
        }

        var grid: EntityBlock = Array(
            repeating: Array(repeating: nil, count: delegate.dimensions.width),
            count: delegate.dimensions.height
        )
        
        for (index, tile) in tiles.enumerated() {
            guard !tile.entities.isEmpty else {
                continue
            }
            grid[index / delegate.dimensions.width][index % delegate.dimensions.width] =
                Set(tile.entities.map {$0.classification})
        }
        return grid
    }
}

class Tile {
    var entities: [Entity] = []
}
