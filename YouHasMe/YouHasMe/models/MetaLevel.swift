import Foundation

class MetaLevel {
    var layer: MetaLevelLayer
    init(layer: MetaLevelLayer) {
        self.layer = layer
    }
}

protocol AbstractLevelLayer {
    var dimensions: Rectangle { get set }
    var tiles: [Tile] { get set }
}

extension AbstractLevelLayer {
    func getTileAt(x: Int, y: Int) -> Tile {
        tiles[x + y * dimensions.width]
    }

    mutating func add(entity: Entity, x: Int, y: Int) {
        tiles[x + y * dimensions.width].entities.append(entity)
    }

    mutating func setTileAt(x: Int, y: Int, tile: Tile) {
        tiles[x + y * dimensions.width] = tile
    }

    func isWithinBounds(x: Int, y: Int) -> Bool {
        x >= 0 && y >= 0 && x < dimensions.width && y < dimensions.height
    }
}

struct MetaLevelLayer: AbstractLevelLayer {
    var tiles: [Tile] = []
    var outlets: [Outlet] = []
    var dimensions: Rectangle
}
