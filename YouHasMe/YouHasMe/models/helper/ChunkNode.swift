import Foundation

struct ChunkNode {
    static var chunkDimensions = 128
    var chunkIdentifier: Point
    var chunkTiles: [[MetaTile]] = Array(
        repeatingFactory:
            Array(repeatingFactory: MetaTile(metaEntity: .space), count: chunkDimensions),
        count: chunkDimensions
    )
}
