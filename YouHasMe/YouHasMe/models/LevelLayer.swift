//
//  LevelLayer.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
struct LevelLayer {
    var dimensions: Rectangle
    var tiles: [Tile]

    init(dimensions: Rectangle) {
        self.dimensions = dimensions
        self.tiles = Array(repeating: Tile(), count: dimensions.width * dimensions.height)
    }
    
    init(dimensions: Rectangle, tiles: [Tile]) {
        self.dimensions = dimensions
        self.tiles = tiles
    }

    mutating func add(entity: Entity, x: Int, y: Int) {
        tiles[x + y * dimensions.width].entities.append(entity)
    }

    func getAbstractRepresentation() -> EntityBlock {
        var grid: EntityBlock = Array(
            repeating: Array(repeating: nil, count: dimensions.width),
            count: dimensions.height
        )

        for (index, tile) in tiles.enumerated() {
            guard !tile.entities.isEmpty else {
                continue
            }
            grid[index / dimensions.width][index % dimensions.width] =
                Set(tile.entities.map { $0.entityType.classification })
        }
        return grid
    }
}

extension LevelLayer {
    func getTileAt(point: Point) -> Tile {
        getTileAt(x: point.x, y: point.y)
    }

    func getTileAt(x: Int, y: Int) -> Tile {
        tiles[x + y * dimensions.width]
    }

    mutating func setTile(_ tile: Tile, at point: Point) {
        setTileAt(x: point.x, y: point.y, tile: tile)
    }

    // TODO: refactor to `setTile` style
    mutating func setTileAt(x: Int, y: Int, tile: Tile) {
        tiles[x + y * dimensions.width] = tile
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
        PersistableLevelLayer(dimensions: dimensions, tiles: tiles.map{$0.toPersistable()})
    }
    
    static func fromPersistable(_ persistableLevelLayer: PersistableLevelLayer) -> LevelLayer {
        LevelLayer(dimensions: persistableLevelLayer.dimensions, tiles: persistableLevelLayer.tiles.map {Tile.fromPersistable($0)})
    }
}

extension LevelLayer: Hashable {}

struct PersistableLevelLayer {
    var dimensions: Rectangle
    var tiles: [PersistableTile]
}

extension PersistableLevelLayer: Codable {}
