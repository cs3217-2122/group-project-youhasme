import Foundation

struct MetaLevel {
    var origin: Point
    var layer: MetaLevelLayer
    init(origin: Point, layer: MetaLevelLayer) {
        self.origin = origin
        self.layer = layer
    }
}

extension MetaLevel: Codable {}

protocol AbstractLevelLayer: Codable {
    associatedtype TileType
    var dimensions: Rectangle { get set }
    var tiles: [TileType] { get set }
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

struct MetaLevelLayer: AbstractLevelLayer {
    typealias TileType = MetaTile
    var tiles: [MetaTile] = []
    var outlets: [Outlet] = []
    var dimensions: Rectangle
}

enum MetaEntityType {
    case blocking
    case nonBlocking
    case space
    case level
}

extension MetaEntityType: Codable {}

struct MetaTile {
    var metaEntity: MetaEntityType
    var hasPlayer: Bool
}

extension MetaTile: Codable {}
