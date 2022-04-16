//
//  ChunkNeighborFinderWrapAroundDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
final class ChunkNeighborFinderWrapAroundDecorator: IdentityFinderDecorator<Point> {
    typealias ChunkIdentifier = Point
    
    override func getNeighborId<T>(of chunk: T) -> NeighborData<Point>
    where T: Chunkable, ChunkIdentifier == T.ChunkIdentifier {
        let extremities = chunk.extremities
        let neighborData = super.getNeighborId(of: chunk)
        return NeighborData(
            topNeighbor: neighborData.topNeighbor.y < extremities.topSide ?
            Point(x: neighborData.topNeighbor.x, y: extremities.bottomSide - 1) : neighborData.topNeighbor,
            leftNeighbor: neighborData.leftNeighbor.x < extremities.leftSide ?
            Point(x: extremities.rightSide - 1, y: neighborData.leftNeighbor.y) : neighborData.leftNeighbor,
            rightNeighbor: neighborData.rightNeighbor.x > extremities.rightSide - 1 ?
            Point(x: extremities.leftSide, y: neighborData.rightNeighbor.y) : neighborData.rightNeighbor,
            bottomNeighbor: neighborData.bottomNeighbor.y > extremities.bottomSide - 1 ?
            Point(x: neighborData.bottomNeighbor.x, y: extremities.topSide) : neighborData.bottomNeighbor
        )
    }
}
