//
//  MultiplayerRoomStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase

struct MultiplayerRoomStorage: MultiplayerRoomStorageProtocol {
    let db = Firestore.firestore()
    static let collectionPath = "rooms"
    
    let dungeonRoomStorage = DungeonRoomStorage()

    func joinRoom(joinCode: String, displayName: String) async throws -> String {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        let querySnapshot = try await db.collection(MultiplayerRoomStorage.collectionPath)
            .whereField("joinCode", isEqualTo: joinCode).getDocuments()
        let documents = querySnapshot.documents
        guard documents.count == 1, let roomDocument = documents.first else {
            fatalError("Join Code should be unique")
        }

        var room = try roomDocument.data(as: MultiplayerRoom.self)
        room.addPlayer(userId: currentUserId, displayName: displayName)
        try db.collection(MultiplayerRoomStorage.collectionPath)
            .document(roomDocument.documentID)
            .setData(from: room)

        return roomDocument.documentID
    }

    func createRoom(displayName: String) async throws -> String {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        var room = MultiplayerRoom(creatorId: currentUserId)
        room.addPlayer(userId: currentUserId, displayName: displayName)
        let roomDocument = db.collection(MultiplayerRoomStorage.collectionPath).document()
        try roomDocument.setData(from: room)
        return roomDocument.documentID
    }

    func updateRoom(room: MultiplayerRoom) throws {
        guard let roomId = room.id else {
            fatalError("room id should exist")
        }
        try db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .setData(from: room)
    }

    func createDungeonRoom(room: MultiplayerRoom) throws {
        guard let roomId = room.id else {
            fatalError("room id and dungeon should exist")
        }
        let roomRef = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
        let dungeonRoomId = try dungeonRoomStorage.createDungeonRoom(room: room, parentRef: roomRef)
        var updatedRoom = room
        updatedRoom.updatePlayerStatusToPlaying(dungeonRoomId: dungeonRoomId)
        try updateRoom(room: updatedRoom)
    }
    
    func updateDungeonRoom(dungeonRoom: DungeonRoom, roomId: String) throws {
        let roomRef = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
        try dungeonRoomStorage.updateDungeonRoom(dungeonRoom: dungeonRoom, parentRef: roomRef)
    }
    
    func createLevelRoom(roomId: String, dungeonRoomId: String, levelId: String) {
        let roomRef = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
        dungeonRoomStorage.createLevelRoom(dungeonRoomId: dungeonRoomId, levelId: levelId, parentRef: roomRef)
    }

    func updateLevelRoom(roomId: String, dungeonRoomId: String, levelRoom: LevelRoom) throws {
        let roomRef = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
        try dungeonRoomStorage.updateLevelRoom(dungeonRoomId: dungeonRoomId, levelRoom: levelRoom, parentRef: roomRef)
    }
}
