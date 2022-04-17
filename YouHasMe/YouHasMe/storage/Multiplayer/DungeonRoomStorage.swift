//
//  DungeonRoomStorage.swift
//  YouHasMe
//
//

import Foundation
import Firebase

struct DungeonRoomStorage {
    let db = Firestore.firestore()
    static let collectionPath = "dungeon"
    
    let levelRoomStorage = LevelRoomStorage()
    
    func createDungeonRoom(room: MultiplayerRoom, parentRef: DocumentReference) throws -> String {
        guard let dungeon = room.dungeon, let dungeonId = room.uploadedDungeonId else {
            fatalError("room id and dungeon should exist")
        }
        let dungeonRoomRef = parentRef.collection(DungeonRoomStorage.collectionPath).document()
        var dungeonRoom = DungeonRoom(dungeon: dungeon, originalDungeonId: dungeonId)
        dungeonRoom.addPlayers(players: Array(room.players.values))
        try dungeonRoomRef.setData(from: dungeonRoom)
        return dungeonRoomRef.documentID
    }
    
    func updateLevelRoom(dungeonRoomId: String, levelRoom: LevelRoom, parentRef: DocumentReference) throws {
        let dungeonRoomRef = parentRef.collection(DungeonRoomStorage.collectionPath).document(dungeonRoomId)
        try levelRoomStorage.updateLevelRoom(levelRoom: levelRoom, parentRef: dungeonRoomRef)
    }
    
    func createLevelRoom(dungeonRoomId: String, levelId: String, parentRef: DocumentReference) {
        let dungeonRoomRef = parentRef.collection(DungeonRoomStorage.collectionPath).document(dungeonRoomId)
        
        dungeonRoomRef.getDocument { querySnapshot, error in
            if let error = error {
                print("couldnt get dungeon room \(error.localizedDescription)")
            }
            
            if let querySnapshot = querySnapshot {
                do {
                    let dungeonRoom = try querySnapshot.data(as: DungeonRoom.self)
                    let uploadedDungeonId = dungeonRoom.originalDungeonId
                    let onlineLevelRef = db.collection(OnlineDungeonStorage.collectionPath)
                        .document(uploadedDungeonId)
                        .collection(OnlineLevelStorage.collectionPath)
                        .document(levelId)
                    onlineLevelRef.getDocument { querySnapshot, error in
                        if let error = error {
                            print("couldnt get online level \(error.localizedDescription)")
                        }
                        
                        if let querySnapshot = querySnapshot {
                            do {
                                let onlineLevel = try querySnapshot.data(as: OnlineLevel.self)
                                let level = onlineLevel.persistedLevel
                                levelRoomStorage.createLevelRoom(level: level, parentRef: dungeonRoomRef)
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
    
    
    func updateDungeonRoom(dungeonRoom: DungeonRoom, parentRef: DocumentReference) throws {
        guard let dungeonRoomId = dungeonRoom.id else {
            fatalError("room id should exist")
        }
        
        let dungeonRoomRef = parentRef.collection(DungeonRoomStorage.collectionPath).document(dungeonRoomId)
        try dungeonRoomRef.setData(from: dungeonRoom)
    }
}
