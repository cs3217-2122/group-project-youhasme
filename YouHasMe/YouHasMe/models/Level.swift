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
    private(set) var layers: BidirectionalArray<LevelLayer>

    init(name: String = "") {
        self.name = name
        layers = BidirectionalArray()
        layers.append(LevelLayer(dimensions: Rectangle(width: 10, height: 10)))
    }

    /// Level zero.
    var baseLevel: LevelLayer {
        getLayerAtIndex(0)
    }

    mutating func resetLayerAtIndex(_ index: Int) {
        guard let originalLayer = layers.getAtIndex(index) else {
            assert(false, "Level does not have layer at index \(index)")
        }

        let emptyLayer = LevelLayer(dimensions: originalLayer.dimensions)
        layers.setAtIndex(index, value: emptyLayer)
    }

    mutating func setName(_ name: String) {
        self.name = name
    }

    mutating func setLevelLayerAtIndex(_ index: Int, value: LevelLayer) {
        layers.setAtIndex(index, value: value)
    }

    func getLayerAtIndex(_ index: Int) -> LevelLayer {
        guard let layer = layers.getAtIndex(index) else {
            assert(false, "Level does not have layer at index \(index)")
        }

        return layer
    }
}

extension Level: Identifiable {
    var id: String {
        name
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

extension LevelLayer: Equatable {
    
}

struct Tile {
    var entities: [Entity] = []
}

extension Rectangle: Codable, Equatable {
}

extension Level: Codable {
}

extension LevelLayer: Codable {
}

extension Tile: Codable, Equatable {
}
