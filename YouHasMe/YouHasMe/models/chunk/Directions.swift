//
//  Directions.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
enum Directions: CaseIterable {
    case top
    case bottom
    case left
    case right
}

extension Directions {
    var opposite: Directions {
        switch self {
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .left:
            return .right
        case .right:
            return .left
        }
    }

    var vectorialOffset: Vector {
        switch self {
        case .top:
            return Vector(dx: 0, dy: -1)
        case .bottom:
            return Vector(dx: 0, dy: 1)
        case .left:
            return Vector(dx: -1, dy: 0)
        case .right:
            return Vector(dx: 1, dy: 0)
        }
    }

    static var vectorialOffsets: [Vector] {
        allCases.map(\.vectorialOffset)
    }

    var neighborDataKeyPath: WritableKeyPath<NeighborData<Point>, Point> {
        switch self {
        case .top:
            return \.topNeighbor
        case .bottom:
            return \.bottomNeighbor
        case .left:
            return \.leftNeighbor
        case .right:
            return \.rightNeighbor
        }
    }

    static var neighborDataKeyPaths: [WritableKeyPath<NeighborData<Point>, Point>] {
        allCases.map(\.neighborDataKeyPath)
    }

    var neighborhoodKeyPath: WritableKeyPath<Level.Neighborhood, Level?> {
        switch self {
        case .top:
            return \.topNeighbor
        case .bottom:
            return \.bottomNeighbor
        case .left:
            return \.leftNeighbor
        case .right:
            return \.rightNeighbor
        }
    }

    static var neighborhoodKeyPaths: [WritableKeyPath<Level.Neighborhood, Level?>] {
        allCases.map(\.neighborhoodKeyPath)
    }
}
