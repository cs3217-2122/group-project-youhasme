//
//  LevelLayer.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation
protocol AbstractLevelLayer: Codable {
    associatedtype TileType
    var dimensions: Rectangle { get set }
    var tiles: [TileType] { get set }
    func getTileAt(point: Point) -> TileType
    mutating func setTile(_ tile: TileType, at point: Point)
    var numPlayers: Int { get set }
}

extension AbstractLevelLayer {
    func getTileAt(point: Point) -> TileType {
        getTileAt(x: point.x, y: point.y)
    }

    func getTileAt(x: Int, y: Int) -> TileType {
        tiles[x + y * dimensions.width]
    }

    mutating func setTile(_ tile: TileType, at point: Point) {
        setTileAt(x: point.x, y: point.y, tile: tile)
    }

    // TODO: refactor to `setTile` style
    mutating func setTileAt(x: Int, y: Int, tile: TileType) {
        tiles[x + y * dimensions.width] = tile
    }
}

struct LevelLayer: AbstractLevelLayer {
    typealias TileType = Tile
    var dimensions: Rectangle
    var tiles: [Tile]
    var numPlayers: Int = 1

    init(dimensions: Rectangle) {
        self.dimensions = dimensions
        self.tiles = Array(repeating: Tile(), count: dimensions.width * dimensions.height)
    }

    init(dimensions: Rectangle, numPlayers: Int) {
        self.init(dimensions: dimensions)
        self.numPlayers = numPlayers
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

extension LevelLayer: Hashable {}
extension LevelLayer: Codable {}
