//
//  ChunkNeighborFinderReversedDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
class ChunkNeighborFinderReversedDecorator: NeighborFinderDelegate {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyNeighborFinderDelegate<Point>

    init<Finder: NeighborFinderDelegate>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyNeighborFinderDelegate(neighborFinder: neighborFinder)
    }

    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: Chunkable, ChunkIdentifier == T.ChunkIdentifier {
        let neighborData = backingFinder.getNeighborId(of: chunk)
        return NeighborData(
            topNeighbor: neighborData.bottomNeighbor,
            leftNeighbor: neighborData.rightNeighbor,
            rightNeighbor: neighborData.leftNeighbor,
            bottomNeighbor: neighborData.bottomNeighbor
        )
    }
}
