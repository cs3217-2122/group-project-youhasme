//
//  ChunkNeighborFinderRandomizerDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
final class ChunkNeighborFinderRandomizerDecorator: IdentityFinderDecorator<Point> {
    typealias ChunkIdentifier = Point

    override func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: Chunkable, ChunkIdentifier == T.ChunkIdentifier {
        let neighborData = super.getNeighborId(of: chunk)
        let permutation = neighborData.toArray().shuffled()
        return NeighborData(
            topNeighbor: permutation[0],
            leftNeighbor: permutation[1],
            rightNeighbor: permutation[2],
            bottomNeighbor: permutation[3]
        )
    }
}
