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
    var layers: BidirectionalArray<LevelLayer>
    init() {
        layers = BidirectionalArray()
    }

    /// Level zero.
    var baseLevel: LevelLayer {
        layers.getAtIndex(0)! // TODO: Fix this
    }
}

struct LevelLayer: AbstractLevelLayer {
    var dimensions: Rectangle
    var tiles: [Tile]

    init(dimensions: Rectangle) {
        self.dimensions = dimensions
        self.tiles = Array(repeating: Tile(), count: dimensions.width * dimensions.height)
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

struct Tile {
    var entities: [Entity] = []
}
