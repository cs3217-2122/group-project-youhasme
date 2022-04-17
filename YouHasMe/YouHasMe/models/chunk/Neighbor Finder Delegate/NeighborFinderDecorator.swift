//
//  NeighborFinderDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 16/4/22.
//

import Foundation
protocol NeighborFinderDecorator: NeighborFinderDelegate {
    var backingFinder: AnyNeighborFinderDelegate<ChunkIdentifier> { get }
    init<N: NeighborFinderDelegate>(finder: N) where N.ChunkIdentifier == ChunkIdentifier
}

extension NeighborFinderDelegate {
    func decorateWith<T: NeighborFinderDecorator>(_ decoratorClass: T.Type)
    -> AnyNeighborFinderDelegate<T.ChunkIdentifier>
    where T.ChunkIdentifier == Self.ChunkIdentifier {
        decoratorClass.init(finder: self).eraseToAnyNeighborFinder()
    }
}
