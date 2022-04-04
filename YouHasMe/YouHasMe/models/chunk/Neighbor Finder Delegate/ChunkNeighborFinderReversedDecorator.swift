//
//  ChunkNeighborFinderReversedDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
class ChunkNeighborFinderReversedDecorator: ChunkNeighborFinderDelegate {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyChunkNeighborFinderDelegate<Point>

    init<Finder: ChunkNeighborFinderDelegate>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyChunkNeighborFinderDelegate(neighborFinder: neighborFinder)
    }

    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: AbstractChunkNode, ChunkIdentifier == T.ChunkIdentifier {
        let neighborData = backingFinder.getNeighborId(of: chunk)
        return NeighborData(
            topNeighbor: neighborData.bottomNeighbor,
            leftNeighbor: neighborData.rightNeighbor,
            rightNeighbor: neighborData.leftNeighbor,
            bottomNeighbor: neighborData.bottomNeighbor
        )
    }
}
