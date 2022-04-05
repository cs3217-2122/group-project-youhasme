import Foundation
import Combine
protocol LevelLocationalDelegate: AnyObject {
    var chunkExtremities: PositionedRectangle { get }
}

class Level: Chunkable {
    struct Neighborhood {
        weak var topNeighbor: Level?
        weak var leftNeighbor: Level?
        weak var rightNeighbor: Level?
        weak var bottomNeighbor: Level?

        var topLeftNeighbor: Level? {
            topNeighbor?.neighbors.leftNeighbor
        }

        var topRightNeighbor: Level? {
            topNeighbor?.neighbors.rightNeighbor
        }

        var bottomLeftNeighbor: Level? {
            bottomNeighbor?.neighbors.leftNeighbor
        }

        var bottomRightNeighbor: Level? {
            bottomNeighbor?.neighbors.rightNeighbor
        }
    }

    var extremities: ExtremityData<Point> {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        let extremityRectangle = delegate.chunkExtremities
        return ExtremityData(
            topExtreme: Point(x: 0, y: extremityRectangle.topSide),
            leftExtreme: Point(x: extremityRectangle.leftSide, y: 0),
            rightExtreme: Point(x: extremityRectangle.rightSide, y: 0),
            bottomExtreme: Point(x: 0, y: extremityRectangle.bottomSide)
        )
    }

    weak var delegate: LevelLocationalDelegate?
    weak var neighborFinderDelegate: AnyNeighborFinderDelegate<Point>?
    var levelStorage: LevelStorage?
    var id: Point
    var name: String
    var dimensions: Rectangle
    var neighbors = Neighborhood()
    typealias ChunkIdentifier = Point

    @Published var layer: LevelLayer

    init(id: Point, name: String, dimensions: Rectangle) {
        self.id = id
        self.dimensions = dimensions
        self.name = name
        layer = LevelLayer(dimensions: dimensions)
    }

    init(id: Point, name: String, dimensions: Rectangle, layer: LevelLayer) {
        self.id = id
        self.dimensions = dimensions
        self.name = name
        self.layer = layer
    }

    /// Level zero.
    var baseLevel: LevelLayer {
        layer
    }

    func resetLayerAtIndex(_ index: Int) {
        let emptyLayer = LevelLayer(dimensions: layer.dimensions)
        layer = emptyLayer
    }

    func setLevelLayerAtIndex(_ index: Int, value: LevelLayer) {
        layer = value
    }

    func getLayerAtIndex(_ index: Int) -> LevelLayer {
        layer
    }

    func getTileAt(point: Point) -> Tile {
        layer.getTileAt(point: point)
    }

    func getTileAt(x: Int, y: Int) -> Tile {
        layer.getTileAt(x: x, y: y)
    }

    func setTile(_ tile: Tile, at point: Point) {
        layer.setTile(tile, at: point)
    }

    func setTileAt(x: Int, y: Int, tile: Tile) {
        layer.setTileAt(x: x, y: y, tile: tile)
    }
}

extension Level: Identifiable {}

extension Level: KeyPathExposable {
    typealias PathRoot = Level

    static var exposedNumericKeyPathsMap: [String: KeyPath<Level, Int>] {
        [:]
    }

    func evaluate(given keyPath: NamedKeyPath<Level, Int>) -> Int {
        self[keyPath: keyPath.keyPath]
    }
}

// MARK: Dynamic loading / unloading
extension Level {
    var areAllNeighborsLoaded: Bool {
        Directions.neighborhoodKeyPaths.allSatisfy {
            neighbors[keyPath: $0] != nil
        }
    }

    func loadNeighbors(at position: Point) -> [Point: Level] {
        guard let neighborFinderDelegate = neighborFinderDelegate else {
            fatalError("Not assigned a neighbor finder.")
        }

        guard let levelStorage = levelStorage else {
            return [:]
        }

        guard !areAllNeighborsLoaded else {
            return [:]
        }

        globalLogger.info("Loading neighbors of level at \(position)")

        var newlyLoadedLevels: [Point: Level] = [:]
        let neighborIdentifiers = neighborFinderDelegate.getNeighborId(of: self)
        for direction in Directions.allCases {
            let offset = direction.vectorialOffset
            let neighborPosition = position.translate(by: offset)
            let neighborhoodKeyPath = direction.neighborhoodKeyPath
            let oppositeNeighborhoodKeyPath = direction.opposite.neighborhoodKeyPath
            let neighborDataKeyPath = direction.neighborDataKeyPath
            if neighbors[keyPath: neighborhoodKeyPath] == nil,
               let neighbor: Level = levelStorage.loadLevel(
                neighborIdentifiers[keyPath: neighborDataKeyPath]
               ) {
                neighbors[keyPath: neighborhoodKeyPath] = neighbor
                neighbor.neighbors[keyPath: oppositeNeighborhoodKeyPath] = self
                newlyLoadedLevels[neighborPosition] = neighbor
            }
        }
        return newlyLoadedLevels
    }
}

// MARK: Persistence
extension Level {
    func toPersistable() -> PersistableLevel {
        PersistableLevel(id: id, name: name, dimensions: dimensions, layer: layer.toPersistable())
    }

    static func fromPersistable(_ persistableLevel: PersistableLevel) -> Level {
        Level(
            id: persistableLevel.id,
            name: persistableLevel.name,
            dimensions: persistableLevel.dimensions,
            layer: LevelLayer.fromPersistable(persistableLevel.layer)
        )
    }
}

struct Tile {
    var entities: [Entity] = []
}

extension Tile: Hashable {}

extension Tile {
    func toPersistable() -> PersistableTile {
        PersistableTile(entities: entities.map { $0.toPersistable() })
    }

    static func fromPersistable(_ persistableTile: PersistableTile) -> Tile {
        Tile(entities: persistableTile.entities.map { Entity.fromPersistable($0) })
    }
}

struct PersistableTile {
    var entities: [PersistableEntity] = []
}

extension PersistableTile: Codable {}
