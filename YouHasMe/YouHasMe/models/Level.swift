import Foundation
import Combine
protocol LevelLocationalDelegate: AnyObject {
    var extremities: Rectangle { get }
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

    weak var locationalDelegate: LevelLocationalDelegate?
    weak var neighborFinderDelegate: AnyNeighborFinderDelegate<Point>?
    weak var generatorDelegate: AnyChunkGeneratorDelegate? {
        didSet {
            guard let generatorDelegate = generatorDelegate else {
                return
            }

            self.layer.tiles = generatorDelegate.generate(
                dimensions: dimensions,
                levelPosition: id,
                extremities: extremities
            )
        }
    }
    var extremities: Rectangle {
        guard let locationalDelegate = locationalDelegate else {
            fatalError("should not be nil")
        }
        return locationalDelegate.extremities
    }
    var levelStorage: LevelStorage?
    var id: Point
    var name: String
    var winCount: Int = 0
    var dimensions: Rectangle
    var neighbors = Neighborhood()
    var hasLoadedNeighbors = false
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
}

extension Level: Identifiable {}

enum LevelKeyPathKeys: String, AbstractKeyPathIdentifierEnum {
    case winCount = "Win Count"
    case youCount = "Number of entities with YOU property"
    case stopCount = "Number of entities with STOP property"
    case pushCount = "Number of entities with PUSH property"
    case babaCount = "Number of Baba entities"
    case wallCount = "Number of Wall entities"
}

// MARK: Queries
extension Level {
    private func countByProperty(_ property: Property) -> Int {
        var count = 0
        for x in 0..<dimensions.width {
            for y in 0..<dimensions.height {
                let point = Point(x: x, y: y)
                count += layer.tiles[point].entities.filter { entity in
                    entity.has(behaviour: .property(property))
                }.count
            }
        }
        return count
    }

    private func countByNounInstance(_ noun: Noun) -> Int {
        var count = 0
        for x in 0..<dimensions.width {
            for y in 0..<dimensions.height {
                let point = Point(x: x, y: y)
                count += layer.tiles[point].entities.filter { entity in
                    if case .nounInstance(let entityNoun) = entity.entityType.classification {
                        return noun == entityNoun
                    }
                    return false
                }.count
            }
        }
        return count
    }

    var youCount: Int {
        countByProperty(.you)
    }

    var stopCount: Int {
        countByProperty(.stop)
    }

    var pushCount: Int {
        countByProperty(.push)
    }

    var babaCount: Int {
        countByNounInstance(.baba)
    }

    var wallCount: Int {
        countByNounInstance(.wall)
    }
}

extension Level: KeyPathExposable {
    typealias PathIdentifier = LevelKeyPathKeys
    typealias PathRoot = Level

    static var exposedNumericKeyPathsMap: [LevelKeyPathKeys: KeyPath<Level, Int>] {
        [
            .winCount: \.winCount,
            .youCount: \.youCount,
            .stopCount: \.stopCount,
            .pushCount: \.pushCount,
            .babaCount: \.babaCount,
            .wallCount: \.wallCount
        ]
    }

    func evaluate(given keyPath: NamedKeyPath<LevelKeyPathKeys, Level, Int>) -> Int {
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
        guard !hasLoadedNeighbors else {
            return [:]
        }
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
        hasLoadedNeighbors = true
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
