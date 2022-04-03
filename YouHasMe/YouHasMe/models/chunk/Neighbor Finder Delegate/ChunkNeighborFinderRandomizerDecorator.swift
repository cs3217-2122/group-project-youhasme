//
//  ChunkNeighborFinderRandomizerDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
class ChunkNeighborFinderRandomizerDecorator: ChunkNeighborFinderDelegate {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyChunkNeighborFinderDelegate<Point>

    init<Finder: ChunkNeighborFinderDelegate>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyChunkNeighborFinderDelegate(neighborFinder: neighborFinder)
    }

    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: AbstractChunkNode, ChunkIdentifier == T.ChunkIdentifier {
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
