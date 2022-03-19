//
//  GameStorage.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 19/3/22.
//

import Foundation

/**
 GameStorage is a simple class used to facilitate the automatic encoding and decoding of stored levels.
 It is expected to store campaigns and other data in future.
 It is used by the ViewModel when loading or saving levels from json files.
 */
struct GameStorage: Codable {
    private(set) var levels: [Level]

    init(levels: [Level]) {
        self.levels = levels
    }
}
