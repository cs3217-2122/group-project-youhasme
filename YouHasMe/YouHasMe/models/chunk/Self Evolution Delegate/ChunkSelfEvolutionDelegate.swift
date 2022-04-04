//
//  ChunkSelfEvolutionDelegate.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 4/4/22.
//

import Foundation
// for multiplayer purposes
enum ChunkChangeEvent {
    case insert(point: Point, inserted: MetaEntityType)
    case update(location: Location, updated: MetaEntityType)
    case delete(location: Location)
}

protocol ChunkSelfEvolutionDelegate: AnyObject {
    var timeStep: Int { get set }
    func evolve(given tiles: [[MetaTile]]) -> [ChunkChangeEvent]
}

class ChunkGrassSpreader: ChunkSelfEvolutionDelegate {
    var timeStep: Int
    init(timeStep: Int) {
        self.timeStep = timeStep
    }

    func evolve(given tiles: [[MetaTile]]) -> [ChunkChangeEvent] {
        var events: [ChunkChangeEvent] = []
        var pointsToSpreadGrass: Set<Point> = []
        for i in 0..<tiles.count {
            for j in 0..<tiles[0].count {
                let point = Point(x: i, y: j)
                for offset in Directions.vectorialOffsets {
                    let pointToSpreadGrass = point.translate(by: offset)
                    pointsToSpreadGrass.insert(pointToSpreadGrass)
                }
            }
        }

        for pointToSpreadGrass in pointsToSpreadGrass {
            events.append(.insert(point: pointToSpreadGrass, inserted: .grass))
        }

        return events
    }
}
