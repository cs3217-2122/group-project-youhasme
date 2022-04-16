//
//  LevelLayer.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct LevelLayer {
    var dimensions: Rectangle
    var tiles: [[Tile]]

    init(dimensions: Rectangle) {
        self.dimensions = dimensions
        self.tiles = Array(
            repeatingFactory:
                Array(repeatingFactory: Tile(), count: dimensions.width),
            count: dimensions.height
        )
    }

    init(dimensions: Rectangle, tiles: [[Tile]]) {
        self.dimensions = dimensions
        self.tiles = tiles
    }

    mutating func add(entity: Entity, x: Int, y: Int) {
        tiles[y][x].entities.append(entity)
    }

    func getAbstractRepresentation() -> EntityBlock {
        var grid: EntityBlock = Array(
            repeating: Array(repeating: nil, count: dimensions.width),
            count: dimensions.height
        )

        for y in 0..<tiles.count {
            for x in 0..<tiles[0].count {
                let tile = tiles[y][x]
                guard !tile.entities.isEmpty else {
                    continue
                }
                grid[y][x] =
                    Set(tile.entities.map { $0.entityType.classification })
            }
        }

        return grid
    }
}

extension LevelLayer {
    func getTileAt(point: Point) -> Tile {
        getTileAt(x: point.x, y: point.y)
    }

    func getTileAt(x: Int, y: Int) -> Tile {
        tiles[y][x]
    }

    mutating func setTile(_ tile: Tile, at point: Point) {
        setTile(tile, x: point.x, y: point.y)
    }

    mutating func setTile(_ tile: Tile, x: Int, y: Int) {
        tiles[y][x] = tile
    }
}

extension LevelLayer: CustomDebugStringConvertible {
    var debugDescription: String {
        var s = ""
        let grid = getAbstractRepresentation()
        for r in 0..<dimensions.height {
            for c in 0..<dimensions.width {
                s += Array(grid[r][c] ?? Set()).description
            }
            s += "\n"
        }
        return s.replacingOccurrences(of: "YouHasMe.Classification.", with: "")
    }
}

extension LevelLayer {
    func toPersistable() -> PersistableLevelLayer {
        PersistableLevelLayer(
            dimensions: dimensions,
            tiles: tiles.map { $0.map { $0.toPersistable() } }
        )
    }

    static func fromPersistable(_ persistableLevelLayer: PersistableLevelLayer) -> LevelLayer {
        LevelLayer(
            dimensions: persistableLevelLayer.dimensions,
            tiles: persistableLevelLayer.tiles.map { $0.map { Tile.fromPersistable($0) } }
        )
    }
}

extension LevelLayer: Hashable {}
