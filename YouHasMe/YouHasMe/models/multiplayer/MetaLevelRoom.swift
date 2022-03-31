//
//  Room.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 30/3/22.
//

import Foundation
import FirebaseFirestoreSwift


// TODO : Generate unique code
struct MetaLevelRoom {
    @DocumentID var id : String?
    var code = Int.random(in: 1...1000)
    let metaLevel: PersistableMetaLevel
//  let creatorId: String
//    var userNames : [String : String] = [:]
    var players: [String] = []
    var playerPositions: [String : Point] = [:]
    
    
    mutating func addPlayer(id: String, position: Point = Point.zero) {
        players.append(id)
        playerPositions[id] = position
    }
}

extension MetaLevelRoom : Codable {
    
}
