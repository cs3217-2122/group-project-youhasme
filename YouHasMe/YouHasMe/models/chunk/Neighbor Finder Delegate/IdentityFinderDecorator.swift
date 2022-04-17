//
//  IdentityFinder.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 16/4/22.
//

import Foundation
class IdentityFinderDecorator<T>: NeighborFinderDecorator where T: DataStringConvertible {
    typealias ChunkIdentifier = T
    var backingFinder: AnyNeighborFinderDelegate<ChunkIdentifier>
    required init<N>(finder: N) where N : NeighborFinderDelegate, N.ChunkIdentifier == T {
        backingFinder = finder.eraseToAnyNeighborFinder()
    }
    
    func getNeighborId<C>(of chunk: C) -> NeighborData<T> where C : Chunkable, C.ChunkIdentifier == T {
        backingFinder.getNeighborId(of: chunk)
    }
}
