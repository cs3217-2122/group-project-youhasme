//
//  DungeonRoom.swift
//  YouHasMe
//
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

enum PlayerStatus {
    case waiting
    case playing(roomId: String, dungeonRoomId: String)
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
    var dungeon: OnlineDungeon?
    var uploadedDungeonId: String?

    mutating func addPlayer(userId: String, displayName: String) {
        let player = Player(id: userId, displayName: displayName)
        players[userId] = player
    }

    mutating func removePlayer(userId: String) {
        players[userId] = nil
    }

    mutating func updatePlayerStatusToPlaying(dungeonRoomId: String) {
        guard let roomId = id else {
            fatalError("Room ID should exist")
        }
        for (playerId, _) in players {
            players[playerId]?.setStatus(status: .playing(roomId: roomId, dungeonRoomId: dungeonRoomId))
        }
    }
}

extension MultiplayerRoom: Codable {}

struct DungeonRoom {
    @DocumentID var id: String?
    var players: [String: Int] = [:]
    var dungeon: OnlineDungeon
    var originalDungeonId: String
    var playerLocations: [String: Point] = [:]
    
    mutating func addPlayers(players: [Player]) {
        for (index, player) in players.enumerated() {
            self.players[player.id] = index+1
            self.playerLocations[player.id] = dungeon.persistedDungeon.entryLevelPosition
        }
    }
}

extension DungeonRoom: Codable {}

struct LevelRoom {
    var persistableLevel: PersistableLevel
    var winCount: Int = 0
}

extension LevelRoom: Codable {}


struct LevelMove {
    @DocumentID var id: String?
    var playerId: String
    var move: ActionType
    @ServerTimestamp var timestamp: Timestamp?
}


extension LevelMove : Codable {
    
}
