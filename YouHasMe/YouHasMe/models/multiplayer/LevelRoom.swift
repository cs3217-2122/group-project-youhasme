//
//  LevelRoom.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct LevelRoom {
    @DocumentID var id: String?
    var persistedLevel: Level
    var players: [String]
    var playerPositions: [String: Point] = [:]
}

extension LevelRoom: Codable {
    
}
