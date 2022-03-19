import Foundation

class Rectangle {
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

class Level {
    var layers: BidirectionalArray<LevelLayer>
    var dimensions: Rectangle
    init(dimensions: Rectangle) {
        layers = BidirectionalArray()
        self.dimensions = dimensions
    }
    
    /// Level zero.
    var baseLevel: LevelLayer {
        layers.getAtIndex(0)
    }
}

extension Level: LevelLayerDelegate {}

class LevelLayer: AbstractLevelLayer {
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
            Set(tile.entities.map {$0.entityType.classification})
        }
        return grid
    }
}

class Tile {
    var entities: [Entity] = []
}
