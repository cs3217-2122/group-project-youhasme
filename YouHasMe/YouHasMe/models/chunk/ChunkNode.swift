import Foundation

protocol AbstractChunkNode {
    associatedtype ChunkIdentifier where ChunkIdentifier: DataStringConvertible
    var extremities: ExtremityData<ChunkIdentifier> { get }
    var identifier: ChunkIdentifier { get set }
}

struct ExtremityData<ChunkIdentifier> {
    var topExtreme: ChunkIdentifier
    var leftExtreme: ChunkIdentifier
    var rightExtreme: ChunkIdentifier
    var bottomExtreme: ChunkIdentifier
}

struct NeighborData<ChunkIdentifier> {
    var topNeighbor: ChunkIdentifier
    var leftNeighbor: ChunkIdentifier
    var rightNeighbor: ChunkIdentifier
    var bottomNeighbor: ChunkIdentifier
}

extension NeighborData {
    func toArray() -> [ChunkIdentifier] {
        [topNeighbor, leftNeighbor, rightNeighbor, bottomNeighbor]
    }
}

struct AnyChunkNode<T>: AbstractChunkNode where T: DataStringConvertible {
    typealias ChunkIdentifier = T
    var identifier: T
    var _extremities: () -> ExtremityData<T>
    var extremities: ExtremityData<T> {
        _extremities()
    }
    init<Node: AbstractChunkNode>(chunk: Node) where Node.ChunkIdentifier == T {
        identifier = chunk.identifier
        _extremities = { chunk.extremities }
    }
}

protocol ChunkNodeLocationalDelegate: AnyObject {
    var chunkExtremities: PositionedRectangle { get }
}

class ChunkNode: AbstractChunkNode {
    struct Neighborhood {
        weak var topNeighbor: ChunkNode?
        weak var leftNeighbor: ChunkNode?
        weak var rightNeighbor: ChunkNode?
        weak var bottomNeighbor: ChunkNode?

        var topLeftNeighbor: ChunkNode? {
            topNeighbor?.neighbors.leftNeighbor
        }

        var topRightNeighbor: ChunkNode? {
            topNeighbor?.neighbors.rightNeighbor
        }

        var bottomLeftNeighbor: ChunkNode? {
            bottomNeighbor?.neighbors.leftNeighbor
        }

        var bottomRightNeighbor: ChunkNode? {
            bottomNeighbor?.neighbors.rightNeighbor
        }
    }

    typealias ChunkIdentifier = Point

    weak var delegate: ChunkNodeLocationalDelegate?
    weak var neighborFinderDelegate: AnyChunkNeighborFinderDelegate<Point>?

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

    static var chunkDimensions = 128
    var chunkStorage: ChunkStorage?
    var identifier: Point
    var chunkDimensions: Int {
        ChunkNode.chunkDimensions
    }
    var chunkTiles: [[MetaTile]]
    var neighbors = Neighborhood()

    init(identifier: Point) {
        self.identifier = identifier
        self.chunkTiles = Array(
            repeatingFactory:
                Array(repeatingFactory: MetaTile(), count: ChunkNode.chunkDimensions),
            count: ChunkNode.chunkDimensions
        )
    }

    init(identifier: Point, chunkTiles: [[MetaTile]]) {
        self.identifier = identifier
        self.chunkTiles = chunkTiles
    }
}

// MARK: Positional data helpers
extension ChunkNode {
    func isInTopFraction(fraction: Double, positionInChunk: Point) -> Bool {
        positionInChunk.y <= Int(Double(chunkDimensions) * fraction)
    }

    func isInBottomFraction(fraction: Double, positionInChunk: Point) -> Bool {
        positionInChunk.y > Int(Double(chunkDimensions) * (1 - fraction))
    }

    func isInLeftFraction(fraction: Double, positionInChunk: Point) -> Bool {
        positionInChunk.x <= Int(Double(chunkDimensions) * fraction)
    }

    func isInRightFraction(fraction: Double, positionInChunk: Point) -> Bool {
        positionInChunk.x > Int(Double(chunkDimensions) * (1 - fraction))
    }
}

extension Array where Element == [MetaTile] {
    subscript(point: Point) -> MetaTile {
        get {
            self[point.y][point.x]
        }
        set {
            self[point.y][point.x] = newValue
        }
    }
}

// MARK: Getters / Setters
extension ChunkNode {
    func getTile(at point: Point) -> MetaTile {
        chunkTiles[point]
    }

    func setTile(_ tile: MetaTile, at point: Point) {
        chunkTiles[point] = tile
    }
}

// MARK: Dynamic loading / unloading
extension ChunkNode {
    var areAllNeighborsLoaded: Bool {
        Directions.neighborhoodKeyPaths.allSatisfy {
            neighbors[keyPath: $0] != nil
        }
    }

    func loadNeighbors(at position: Point) -> [Point: ChunkNode] {
        guard let neighborFinderDelegate = neighborFinderDelegate else {
            fatalError("Not assigned a neighbor finder.")
        }

        guard let chunkStorage = chunkStorage else {
            return [:]
        }

        guard !areAllNeighborsLoaded else {
            return [:]
        }

        globalLogger.info("Loading neighbors of chunk at \(position)")

        var newlyLoadedChunks: [Point: ChunkNode] = [:]
        let neighborIdentifiers = neighborFinderDelegate.getNeighborId(of: self)
        for direction in Directions.allCases {
            let offset = direction.vectorialOffset
            let neighborPosition = position.translate(by: offset)
            let neighborhoodKeyPath = direction.neighborhoodKeyPath
            let oppositeNeighborhoodKeyPath = direction.opposite.neighborhoodKeyPath
            let neighborDataKeyPath = direction.neighborDataKeyPath
            if neighbors[keyPath: neighborhoodKeyPath] == nil,
               let neighbor: ChunkNode = chunkStorage.loadChunk(
                identifier: neighborIdentifiers[keyPath: neighborDataKeyPath].dataString
               ) {
                neighbors[keyPath: neighborhoodKeyPath] = neighbor
                neighbor.neighbors[keyPath: oppositeNeighborhoodKeyPath] = self
                newlyLoadedChunks[neighborPosition] = neighbor
            }
        }
        return newlyLoadedChunks
    }
}

// MARK: Persistence
extension ChunkNode {
    func toPersistable() -> PersistableChunkNode {
        PersistableChunkNode(
            identifier: identifier,
            chunkTiles: chunkTiles.map { $0.map { $0.toPersistable() } }
        )
    }

    static func fromPersistable(_ persistableChunkNode: PersistableChunkNode) -> ChunkNode {
        ChunkNode(
            identifier: persistableChunkNode.identifier,
            chunkTiles: persistableChunkNode.chunkTiles.map {
                $0.map {
                    MetaTile.fromPersistable($0)
                }
            }
        )
    }
}
