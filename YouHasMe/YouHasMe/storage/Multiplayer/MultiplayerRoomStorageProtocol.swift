//
//  MultiplayerRoomStorageProtocol.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation

protocol MultiplayerRoomStorageProtocol {
    func joinRoom(joinCode: String, displayName: String) async throws -> String
    func createRoom(displayName: String) async throws -> String
    func updateRoom(room: MultiplayerRoom) throws
    func createDungeonRoom(room: MultiplayerRoom) throws
    func updateDungeonRoom(dungeonRoom: DungeonRoom, roomId: String) throws
    func createLevelRoom(roomId: String, dungeonRoomId: String, levelId: String)
    func updateLevelRoom(roomId: String, dungeonRoomId: String, levelRoom: LevelRoom) throws
}
