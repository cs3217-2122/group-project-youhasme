//
//  ChunkNeighborFinderReversedDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
final class ChunkNeighborFinderReversedDecorator: IdentityFinderDecorator<Point> {
    typealias ChunkIdentifier = Point

    override func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: Chunkable, ChunkIdentifier == T.ChunkIdentifier {
        let neighborData = super.getNeighborId(of: chunk)
        return NeighborData(
            topNeighbor: neighborData.bottomNeighbor,
            leftNeighbor: neighborData.rightNeighbor,
            rightNeighbor: neighborData.leftNeighbor,
            bottomNeighbor: neighborData.bottomNeighbor
        )
    }
}
