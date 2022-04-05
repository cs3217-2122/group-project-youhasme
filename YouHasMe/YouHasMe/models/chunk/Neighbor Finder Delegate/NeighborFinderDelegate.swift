//
//  ChunkNeighborFinderDelegate.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
protocol NeighborFinderDelegate: AnyObject {
    associatedtype ChunkIdentifier where ChunkIdentifier: DataStringConvertible
    func getNeighborId<T: Chunkable>(of chunk: T) -> NeighborData<ChunkIdentifier>
    where T.ChunkIdentifier == ChunkIdentifier
}

extension NeighborFinderDelegate {
    func eraseToAnyNeighborFinder() -> AnyNeighborFinderDelegate<ChunkIdentifier> {
        AnyNeighborFinderDelegate(neighborFinder: self)
    }
}

class AnyNeighborFinderDelegate<T>: NeighborFinderDelegate where T: DataStringConvertible {
    typealias ChunkIdentifier = T
    private var _getNeighborId: (AnyChunkable<T>) -> NeighborData<ChunkIdentifier>

    init<Finder: NeighborFinderDelegate>(neighborFinder: Finder)
    where Finder.ChunkIdentifier == T {
        _getNeighborId = neighborFinder.getNeighborId(of:)
    }

    func getNeighborId<Node: Chunkable>(of chunk: Node) -> NeighborData<T> where Node.ChunkIdentifier == T {
        _getNeighborId(AnyChunkable(chunk: chunk))
    }
}
