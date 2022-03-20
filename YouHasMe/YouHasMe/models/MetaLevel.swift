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
}

struct MetaLevelLayer: AbstractLevelLayer {
    var tiles: [Tile] = []
    var outlets: [Outlet] = []
    var dimensions: Rectangle
}
