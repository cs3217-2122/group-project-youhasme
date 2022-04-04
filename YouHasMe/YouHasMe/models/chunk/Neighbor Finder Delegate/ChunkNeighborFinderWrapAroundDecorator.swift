//
//  ChunkNeighborFinderWrapAroundDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
class ChunkNeighborFinderWrapAroundDecorator: ChunkNeighborFinderDelegate {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyChunkNeighborFinderDelegate<Point>

    init<Finder: ChunkNeighborFinderDelegate>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyChunkNeighborFinderDelegate(neighborFinder: neighborFinder)
    }

    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: AbstractChunkNode, ChunkIdentifier == T.ChunkIdentifier {
        let extremities = chunk.extremities
        let neighborData = backingFinder.getNeighborId(of: chunk)
        return NeighborData(
            topNeighbor: neighborData.topNeighbor.y < extremities.topExtreme.y ?
            Point(x: neighborData.topNeighbor.x, y: extremities.bottomExtreme.y) : neighborData.topNeighbor,
            leftNeighbor: neighborData.leftNeighbor.x < extremities.leftExtreme.x ?
            Point(x: extremities.rightExtreme.x, y: neighborData.leftNeighbor.y) : neighborData.leftNeighbor,
            rightNeighbor: neighborData.rightNeighbor.x > extremities.rightExtreme.x ?
            Point(x: extremities.leftExtreme.x, y: neighborData.rightNeighbor.y) : neighborData.rightNeighbor,
            bottomNeighbor: neighborData.bottomNeighbor.y > extremities.bottomExtreme.y ?
            Point(x: neighborData.bottomNeighbor.x, y: extremities.topExtreme.y) : neighborData.bottomNeighbor
        )
    }
}
