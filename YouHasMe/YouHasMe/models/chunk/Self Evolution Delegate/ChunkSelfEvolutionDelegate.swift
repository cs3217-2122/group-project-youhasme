//
//  ChunkSelfEvolutionDelegate.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
protocol ChunkSelfEvolutionDelegate {
    var timeStep: Int { get set }
    func evolve(given tiles: [[MetaTile]]) -> [[MetaTile]]
}
