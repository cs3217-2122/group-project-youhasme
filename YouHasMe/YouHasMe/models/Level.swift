import Foundation

struct Rectangle {
    var width: Int
    var height: Int
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    var numCells: Int {
        width * height
    }
}

struct Level {
    var name: String
    var layers: BidirectionalArray<LevelLayer>

    init(name: String = "") {
        self.name = name
        layers = BidirectionalArray()
        layers.append(LevelLayer(dimensions: Rectangle(width: 30, height: 30)))
    }
    
    /// Level zero.
    var baseLevel: LevelLayer {
        guard let baseLayer = layers.getAtIndex(0) else {
            assert(false, "Level does not have a base layer")
        }

        return baseLayer
    }
}

struct LevelLayer: AbstractLevelLayer {
    var dimensions: Rectangle
    var tiles: [Tile]
    
    init(dimensions: Rectangle) {
        self.dimensions = dimensions
        self.tiles = Array(repeating: Tile(), count: dimensions.width*dimensions.height)
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
            Set(tile.entities.map {$0.entityType.classification})
        }
        return grid
    }
}

struct Tile {
    var entities: [Entity] = []
}
