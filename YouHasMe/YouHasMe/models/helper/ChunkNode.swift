import Foundation

protocol AbstractChunkNode {
    associatedtype ChunkIdentifier
    var identifier: ChunkIdentifier { get set }
}

protocol AbstractChunkNeighborFinder {
    associatedtype ChunkIdentifier
    func getNeighborId<T: AbstractChunkNode>(of chunk: T) -> ChunkIdentifier where T.ChunkIdentifier == ChunkIdentifier
}

struct AnyChunkNode<T>: AbstractChunkNode {
    typealias ChunkIdentifier = T
    var identifier: T
    init<S: AbstractChunkNode>(chunk: S) where S.ChunkIdentifier == T {
        identifier = chunk.identifier
    }
}

struct AnyChunkNeighborFinder<T>: AbstractChunkNeighborFinder {
    typealias ChunkIdentifier = T
    private var _getNeighborId: (AnyChunkNode<T>) -> T
    
    init<S: AbstractChunkNeighborFinder>(neighborFinder: S) where S.ChunkIdentifier == T {
        _getNeighborId = neighborFinder.getNeighborId(of:)
    }
    
    func getNeighborId<S: AbstractChunkNode>(of chunk: S) -> T where S.ChunkIdentifier == T {
        _getNeighborId(AnyChunkNode(chunk: chunk))
    }
    
}


struct ChunkNode: AbstractChunkNode {
    typealias ChunkIdentifier = Point
    static var chunkDimensions = 128
    var identifier: Point
    var chunkTiles: [[MetaTile]] = Array(
        repeatingFactory:
            Array(repeatingFactory: MetaTile(metaEntity: .space), count: chunkDimensions),
        count: chunkDimensions
    )
    var neighborFinder: AnyChunkNeighborFinder<Point>
}
