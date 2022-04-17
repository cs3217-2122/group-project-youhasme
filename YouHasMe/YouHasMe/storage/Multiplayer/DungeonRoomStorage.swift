//
//  DungeonRoomStorage.swift
//  YouHasMe
//
//

import Foundation
import Firebase

struct OnlineDungeonStorage {
    let db = Firestore.firestore()
    static let dungeonCollectionPath = "dungeons"
    static let levelCollectionPath = "levels"

    func upload(dungeon: Dungeon) throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let batch = db.batch()
        let onlineDungeon = OnlineDungeon(uploaderId: currentUserId, persistedDungeon: dungeon.toPersistable())
        let dungeonRef = try uploadOnlineDungeon(onlineDungeon: onlineDungeon, batch: batch)
        let onlineLevels = getOnlineLevels(dungeon: dungeon)
//        print("COUNT\(onlineLevels.count)")
        _ = try uploadOnlineLevels(onlineLevels: onlineLevels, batch: batch, parentRef: dungeonRef)
        batch.commit()
    }
    
    private func uploadOnlineDungeon(onlineDungeon: OnlineDungeon, batch: WriteBatch) throws -> DocumentReference {
        let dungeonRef = db.collection(OnlineDungeonStorage.dungeonCollectionPath).document()
        try batch.setData(from: onlineDungeon, forDocument: dungeonRef)
        return dungeonRef
    }

    private func getOnlineLevels(dungeon: Dungeon) -> [OnlineLevel] {
        let levelStorage = dungeon.levelStorage
        let levelLodables = levelStorage.getAllLoadables()
//        print(levelLodables)
        let onlineLevels: [OnlineLevel] = levelLodables.compactMap {  loadable in
//            print(loadable.name)
            guard let persistedLevel: PersistableLevel = levelStorage.loadLevel(loadable.name) else {
                return nil
            }
            return OnlineLevel(persistedLevel: persistedLevel)
        }
        return onlineLevels
    }

    private func uploadOnlineLevels(onlineLevels: [OnlineLevel], batch: WriteBatch, parentRef: DocumentReference) throws -> [DocumentReference] {
        var levelRefs: [DocumentReference] = []
        for onlineLevel in onlineLevels {
            let id = onlineLevel.persistedLevel.id.dataString
            let levelRef = parentRef.collection(OnlineDungeonStorage.levelCollectionPath).document(id)
            try batch.setData(from: onlineLevel, forDocument: levelRef)
            levelRefs.append(levelRef)
        }
        return levelRefs
    }
}

struct MultiplayerRoomStorage {
    let db = Firestore.firestore()
    static let collectionPath = "rooms"
    static let dungeonCollectionPath = "dungeon"
    static let levelCollectionPath = "level"

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
        guard let roomId = room.id, let dungeon = room.dungeon, let dungeonId = room.uploadedDungeonId else {
            fatalError("room id and dungeon should exist")
        }
        let roomRef = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
        let dungeonRoomRef = roomRef.collection(MultiplayerRoomStorage.dungeonCollectionPath).document()
        var dungeonRoom = DungeonRoom(dungeon: dungeon, originalDungeonId: dungeonId)
        dungeonRoom.addPlayers(players: Array(room.players.values))
        try dungeonRoomRef.setData(from: dungeonRoom)
        var updatedRoom = room
        updatedRoom.updatePlayerStatusToPlaying(dungeonRoomId: dungeonRoomRef.documentID)
        try updateRoom(room: updatedRoom)
    }
    
    func updateDungeonRoom(dungeonRoom: DungeonRoom, roomId: String) throws {
        guard let dungeonRoomId = dungeonRoom.id else {
            fatalError("room id should exist")
        }
        try db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(MultiplayerRoomStorage.dungeonCollectionPath)
            .document(dungeonRoomId)
            .setData(from: dungeonRoom)
    }
    
    func updateLevelRoom(roomId: String, dungeonRoomId: String, levelRoom: LevelRoom) throws {
        let levelRoomId = levelRoom.persistableLevel.id.dataString
        try db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(MultiplayerRoomStorage.dungeonCollectionPath)
            .document(dungeonRoomId)
            .collection(MultiplayerRoomStorage.levelCollectionPath)
            .document(levelRoomId)
            .setData(from: levelRoom)
    }
    
    func createLevelRoomIfNotExists(roomId: String, dungeonRoomId: String, levelId: String) {
        let roomRef = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
        let dungeonRoomRef = roomRef.collection(MultiplayerRoomStorage.dungeonCollectionPath).document(dungeonRoomId)
        let levelRoomRef = dungeonRoomRef.collection(MultiplayerRoomStorage.levelCollectionPath).document(levelId)
        dungeonRoomRef.getDocument { querySnapshot, error in
            if let error = error {
                print("couldnt get dungeon room \(error.localizedDescription)")
            }
            
            if let querySnapshot = querySnapshot {
                do {
                    let dungeonRoom = try querySnapshot.data(as: DungeonRoom.self)
                    let uploadedDungeonId = dungeonRoom.originalDungeonId
                    let onlineLevelRef = db.collection(OnlineDungeonStorage.dungeonCollectionPath)
                        .document(uploadedDungeonId)
                        .collection(OnlineDungeonStorage.levelCollectionPath)
                        .document(levelId)
                    onlineLevelRef.getDocument { querySnapshot, error in
                        if let error = error {
                            print("couldnt get online level \(error.localizedDescription)")
                        }
                        
                        if let querySnapshot = querySnapshot {
                            do {
                                let onlineLevel = try querySnapshot.data(as: OnlineLevel.self)
                                let level = onlineLevel.persistedLevel
                                let levelRoom = LevelRoom(persistableLevel: level)
                                levelRoomRef.getDocument { querySnapshot, error in
                                    if let error = error {
                                        print("error \(error.localizedDescription)")
                                    }
                                    
                                    if let querySnapshot = querySnapshot {
                                        if !querySnapshot.exists {
                                            do {
                                               try  levelRoomRef.setData(from: levelRoom)
                                            } catch {
                                                print("error \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }
                            } catch {
                                print("error \(error.localizedDescription)")
                            }
                        }
                    }
                } catch {
                    print("error \(error.localizedDescription)")
                }
            }
        }
    }
}

//struct DungeonRoomStorage {
//    let db = Firestore.firestore()
//}
