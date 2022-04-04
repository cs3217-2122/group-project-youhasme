//
//  ChunkNeighborFinderDelegate.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
protocol ChunkNeighborFinderDelegate: AnyObject {
    associatedtype ChunkIdentifier where ChunkIdentifier: DataStringConvertible
    func getNeighborId<T: AbstractChunkNode>(of chunk: T) -> NeighborData<ChunkIdentifier>
    where T.ChunkIdentifier == ChunkIdentifier
}

extension ChunkNeighborFinderDelegate {
    func eraseToAnyNeighborFinder() -> AnyChunkNeighborFinderDelegate<ChunkIdentifier> {
        AnyChunkNeighborFinderDelegate(neighborFinder: self)
    }
}

class AnyChunkNeighborFinderDelegate<T>: ChunkNeighborFinderDelegate where T: DataStringConvertible {
    typealias ChunkIdentifier = T
    private var _getNeighborId: (AnyChunkNode<T>) -> NeighborData<ChunkIdentifier>

    init<Finder: ChunkNeighborFinderDelegate>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == T {
        _getNeighborId = neighborFinder.getNeighborId(of:)
    }

    func getNeighborId<Node: AbstractChunkNode>(of chunk: Node) -> NeighborData<T> where Node.ChunkIdentifier == T {
        _getNeighborId(AnyChunkNode(chunk: chunk))
    }
}
