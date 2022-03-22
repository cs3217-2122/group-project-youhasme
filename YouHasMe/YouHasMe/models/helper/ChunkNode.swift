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

protocol AbstractChunkNeighborFinder {
    associatedtype ChunkIdentifier where ChunkIdentifier: DataStringConvertible
    func getNeighborId<T: AbstractChunkNode>(of chunk: T) -> NeighborData<ChunkIdentifier> where T.ChunkIdentifier == ChunkIdentifier
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

struct AnyChunkNeighborFinder<T>: AbstractChunkNeighborFinder where T: DataStringConvertible {
    typealias ChunkIdentifier = T
    private var _getNeighborId: (AnyChunkNode<T>) -> NeighborData<ChunkIdentifier>
    
    init<Finder: AbstractChunkNeighborFinder>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == T {
        _getNeighborId = neighborFinder.getNeighborId(of:)
    }
    
    func getNeighborId<Node: AbstractChunkNode>(of chunk: Node) -> NeighborData<T> where Node.ChunkIdentifier == T {
        _getNeighborId(AnyChunkNode(chunk: chunk))
    }
}

struct ImmediateNeighborhoodChunkNeighborFinder: AbstractChunkNeighborFinder {
    typealias ChunkIdentifier = Point
    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T : AbstractChunkNode, ChunkIdentifier == T.ChunkIdentifier {
        let currentChunkIdentifier = chunk.identifier
        return NeighborData(
            topNeighbor: currentChunkIdentifier.translateY(dy: -1),
            leftNeighbor: currentChunkIdentifier.translateX(dx: -1),
            rightNeighbor: currentChunkIdentifier.translateX(dx: 1),
            bottomNeighbor: currentChunkIdentifier.translateY(dy: 1)
        )
    }
}

struct ChunkNeighborFinderReversedDecorator: AbstractChunkNeighborFinder {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyChunkNeighborFinder<Point>
    
    init<Finder: AbstractChunkNeighborFinder>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyChunkNeighborFinder(neighborFinder: neighborFinder)
    }
    
    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T : AbstractChunkNode, ChunkIdentifier == T.ChunkIdentifier {
        let neighborData = backingFinder.getNeighborId(of: chunk)
        return NeighborData(
            topNeighbor: neighborData.bottomNeighbor,
            leftNeighbor: neighborData.rightNeighbor,
            rightNeighbor: neighborData.leftNeighbor,
            bottomNeighbor: neighborData.bottomNeighbor
        )
    }
}

struct ChunkNeighborFinderWrapAroundDecorator: AbstractChunkNeighborFinder {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyChunkNeighborFinder<Point>
    
    init<Finder: AbstractChunkNeighborFinder>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyChunkNeighborFinder(neighborFinder: neighborFinder)
    }
    
    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T : AbstractChunkNode, ChunkIdentifier == T.ChunkIdentifier {
        let extremities = chunk.extremities
        let neighborData = backingFinder.getNeighborId(of: chunk)
        return NeighborData(
            topNeighbor: neighborData.topNeighbor.y < extremities.topExtreme.y ?
            Point(x: neighborData.topNeighbor.x, y: extremities.bottomExtreme.y) : neighborData.topNeighbor,
            leftNeighbor: neighborData.leftNeighbor.x < extremities.leftExtreme.x ?
            Point(x: extremities.rightExtreme.x, y: neighborData.leftNeighbor.y) : neighborData.leftNeighbor,
            rightNeighbor: neighborData.rightNeighbor.x > extremities.rightExtreme.x ?
            Point(x: extremities.leftExtreme.x, y: neighborData.rightNeighbor.y) : neighborData.rightNeighbor,
            bottomNeighbor: neighborData.bottomNeighbor.y > extremities.bottomExtreme.y ?
            Point(x: neighborData.bottomNeighbor.x, y: extremities.topExtreme.y) : neighborData.bottomNeighbor
        )
    }
}

struct ChunkNeighborFinderRandomizerDecorator: AbstractChunkNeighborFinder {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyChunkNeighborFinder<Point>
    
    init<Finder: AbstractChunkNeighborFinder>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyChunkNeighborFinder(neighborFinder: neighborFinder)
    }
    
    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T : AbstractChunkNode, ChunkIdentifier == T.ChunkIdentifier {
        let neighborData = backingFinder.getNeighborId(of: chunk)
        let permutation = neighborData.toArray().shuffled()
        return NeighborData(
            topNeighbor: permutation[0],
            leftNeighbor: permutation[1],
            rightNeighbor: permutation[2],
            bottomNeighbor: permutation[3]
        )
    }
}


protocol ChunkNodeDelegate: AnyObject {
    var chunkExtremities: PositionedRectangle { get }
}

struct ChunkNode: AbstractChunkNode {
    typealias ChunkIdentifier = Point
    
    weak var delegate: ChunkNodeDelegate?
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
    var identifier: Point
    var chunkTiles: [[MetaTile]]
    var neighborFinder: AnyChunkNeighborFinder<Point>
    init<Finder: AbstractChunkNeighborFinder>(identifier: Point, neighborFinder: Finder
    )
    where Finder.ChunkIdentifier == Point {
        self.identifier = identifier
        self.neighborFinder = AnyChunkNeighborFinder(neighborFinder: neighborFinder)
        chunkTiles = Array(
            repeatingFactory:
                Array(repeatingFactory: MetaTile(metaEntity: .space), count: ChunkNode.chunkDimensions),
            count: ChunkNode.chunkDimensions
        )
    }
    
    init(identifier: Point) {
        self.init(identifier: identifier, neighborFinder: ImmediateNeighborhoodChunkNeighborFinder())
    }
    
    init(identifier: Point, chunkTiles: [[MetaTile]]) {
        self.identifier = identifier
        self.chunkTiles = chunkTiles
        self.neighborFinder = AnyChunkNeighborFinder(neighborFinder: ImmediateNeighborhoodChunkNeighborFinder()
        )
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
