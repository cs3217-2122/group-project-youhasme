//
//  ChunkNeighborFinderWrapAroundDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
class ChunkNeighborFinderWrapAroundDecorator: NeighborFinderDelegate {
    typealias ChunkIdentifier = Point
    var backingFinder: AnyNeighborFinderDelegate<Point>

    init<Finder: NeighborFinderDelegate>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == Point {
        backingFinder = AnyNeighborFinderDelegate(neighborFinder: neighborFinder)
    }

    func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: Chunkable, ChunkIdentifier == T.ChunkIdentifier {
        let extremities = chunk.extremities
        let neighborData = backingFinder.getNeighborId(of: chunk)
        return NeighborData(
            topNeighbor: neighborData.topNeighbor.y < extremities.topSide ?
            Point(x: neighborData.topNeighbor.x, y: extremities.bottomSide) : neighborData.topNeighbor,
            leftNeighbor: neighborData.leftNeighbor.x < extremities.leftSide ?
            Point(x: extremities.rightSide, y: neighborData.leftNeighbor.y) : neighborData.leftNeighbor,
            rightNeighbor: neighborData.rightNeighbor.x > extremities.rightSide ?
            Point(x: extremities.leftSide, y: neighborData.rightNeighbor.y) : neighborData.rightNeighbor,
            bottomNeighbor: neighborData.bottomNeighbor.y > extremities.bottomSide ?
            Point(x: neighborData.bottomNeighbor.x, y: extremities.topSide) : neighborData.bottomNeighbor
        )
    }
}
