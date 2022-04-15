//
//  DungeonRoom.swift
//  YouHasMe
//
//

import Foundation
import FirebaseFirestoreSwift

struct DungeonRoom {
    @DocumentID var id: String?
    var name: String
    var joinCode = String(Int.random(in: 1000...100_000))
    var playerIds: Set<String> = []
    var onlineDungeonId: String?
    
    mutating func addPlayer(userId: String) {
        playerIds.insert(userId)
    }
    
    mutating func removePlayer(userId: String) {
        playerIds.remove(userId)
    }
}

extension DungeonRoom: Codable {
    
}
