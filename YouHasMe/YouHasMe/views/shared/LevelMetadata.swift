//
//  LevelMetadata.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 9/4/22.
//

import Foundation

struct LevelMetadata: Identifiable, CustomStringConvertible {
    var id: Point
    var name: String

    var description: String {
        name
    }

    static func levelNameToPositionMapToMetadata(_ levelNameToPositionMap: [String: Point]) -> [LevelMetadata] {
        levelNameToPositionMap.sorted(by: { entry1, entry2 in
            let (_, value1) = entry1
            let (_, value2) = entry2
            return value1 < value2
        }).map { (levelName: String, levelPosition: Point) in
            LevelMetadata(id: levelPosition, name: levelName)
        }
    }
}
