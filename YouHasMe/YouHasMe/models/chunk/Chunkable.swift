import Foundation

protocol Chunkable {
    associatedtype ChunkIdentifier where ChunkIdentifier: DataStringConvertible
    var id: ChunkIdentifier { get set }
    var extremities: ExtremityData<ChunkIdentifier> { get }
}

struct AnyChunkable<T>: Chunkable where T: DataStringConvertible {
    typealias ChunkIdentifier = T
    var id: T
    var extremities: ExtremityData<T>
    init<Node: Chunkable>(chunk: Node) where Node.ChunkIdentifier == T {
        id = chunk.id
        extremities = chunk.extremities
    }
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
