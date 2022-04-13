//
//  ChunkNeighborFinderRandomizerDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
class ChunkNeighborFinderRandomizerDecorator: NeighborFinderDelegate {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyNeighborFinderDelegate<Point>

    init<Finder: NeighborFinderDelegate>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyNeighborFinderDelegate(neighborFinder: neighborFinder)
    }

    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: Chunkable, ChunkIdentifier == T.ChunkIdentifier {
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
