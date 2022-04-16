//
//  DungeonRoom.swift
//  YouHasMe
//
//

import Foundation
import FirebaseFirestoreSwift

enum PlayerStatus {
    case waiting
    case playing(dungeonRoomId: String)
}

extension PlayerStatus: Codable {}

struct Player {
    var id: String
    var displayName: String
    var status: PlayerStatus = .waiting

    mutating func setStatus(status: PlayerStatus) {
        self.status = status
    }
}

extension Player: Codable {}

struct MultiplayerRoom {
    @DocumentID var id: String?
    var creatorId: String
    var joinCode = String(Int.random(in: 1_000...100_000))
    var players: [String: Player] = [:]
    var dungeon: PersistableDungeon?

    mutating func addPlayer(userId: String, displayName: String) {
        let player = Player(id: userId, displayName: displayName)
        players[userId] = player
    }

    mutating func removePlayer(userId: String) {
        players[userId] = nil
    }
    
    mutating func updatePlayerStatusToPlaying(dungeonRoomId: String) {
        for (playerId, _) in players {
            players[playerId]?.setStatus(status: .playing(dungeonRoomId: dungeonRoomId))
        }
    }
}

extension MultiplayerRoom: Codable {}

struct DungeonRoom {
    @DocumentID var id: String?
    var players: [Int: Player] = [:]
    var dungeon: PersistableDungeon
    
    
    mutating func addPlayers(players: [Player]) {
        for (index, player) in players.enumerated() {
            self.players[index+1] = player
        }
    }
}

extension DungeonRoom: Codable {
    
}
