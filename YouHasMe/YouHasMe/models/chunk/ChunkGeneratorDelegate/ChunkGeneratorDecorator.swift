//
//  ChunkGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 16/4/22.
//

import Foundation
protocol ChunkGeneratorDecorator: ChunkGeneratorDelegate {
    var backingGenerator: AnyChunkGeneratorDelegate { get }
    init<T: ChunkGeneratorDelegate>(generator: T)
}
