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

    func isWithinBounds(x: Int, y: Int) -> Bool {
        x >= 0 && y >= 0 && x < dimensions.width && y < dimensions.height
    }
}

struct LevelLayer: AbstractLevelLayer {
    typealias TileType = Tile
    var dimensions: Rectangle
    var tiles: [Tile]

    init(dimensions: Rectangle) {
        self.dimensions = dimensions
        self.tiles = Array(repeating: Tile(), count: dimensions.width * dimensions.height)
    }

    mutating func add(entity: Entity, x: Int, y: Int) {
        tiles[x + y * dimensions.width].entities.append(entity)
    }

    // Returns locations of entities with specified behaviour
    func getLocationsOf(behaviour: Behaviour) -> Set<Location> {
        var locations: Set<Location> = []
        for y in 0..<dimensions.height {
            for x in 0..<dimensions.width {
                let entities = getTileAt(x: x, y: y).entities
                for i in 0..<entities.count where entities[i].activeBehaviours.contains(behaviour) {
                    locations.insert(Location(x: x, y: y, z: i))
                }
            }
        }
        return locations
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

extension LevelLayer: Equatable {}
extension LevelLayer: Codable {}
