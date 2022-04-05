//
//  ImmediateNeighborhoodChunkNeighborFinder.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
class ImmediateNeighborhoodChunkNeighborFinder: NeighborFinderDelegate {
    typealias ChunkIdentifier = Point
    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: Chunkable, ChunkIdentifier == T.ChunkIdentifier {
        let currentChunkIdentifier = chunk.identifier
        return NeighborData(
            topNeighbor: currentChunkIdentifier.translateY(dy: -1),
            leftNeighbor: currentChunkIdentifier.translateX(dx: -1),
            rightNeighbor: currentChunkIdentifier.translateX(dx: 1),
            bottomNeighbor: currentChunkIdentifier.translateY(dy: 1)
        )
    }
}
