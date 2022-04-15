//
//  DungeonRoomStorage.swift
//  YouHasMe
//
//

import Foundation
import Firebase

struct OnlineDungeonStorage {
    let db = Firestore.firestore()
    let dungeonCollectionPath = "dungeons"
    let levelCollectionPath = "levels"

    func upload(dungeon: Dungeon) throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let batch = db.batch()
        let onlineDungeon = OnlineDungeon(uploaderId: currentUserId, persistedDungeon: dungeon.toPersistable())
        let dungeonRef = try uploadOnlineDungeon(onlineDungeon: onlineDungeon, batch: batch)
        let onlineLevels = getOnlineLevels(dungeon: dungeon)
        print("COUNT\(onlineLevels.count)")
        _ = try uploadOnlineLevels(onlineLevels: onlineLevels, batch: batch, parentRef: dungeonRef)
        batch.commit()
    }
    
    private func uploadOnlineDungeon(onlineDungeon: OnlineDungeon, batch: WriteBatch) throws -> DocumentReference {
        let dungeonRef = db.collection(dungeonCollectionPath).document()
        try batch.setData(from: onlineDungeon, forDocument: dungeonRef)
        return dungeonRef
    }

    private func getOnlineLevels(dungeon: Dungeon) -> [OnlineLevel] {
        let levelStorage = dungeon.levelStorage
        let levelLodables = levelStorage.getAllLoadables()
        print(levelLodables)
        let onlineLevels: [OnlineLevel] = levelLodables.compactMap {  loadable in
            print(loadable.name)
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
            let levelRef = parentRef.collection(levelCollectionPath).document()
            try batch.setData(from: onlineLevel, forDocument: levelRef)
            levelRefs.append(levelRef)
        }
        return levelRefs
    }
}

struct DungeonRoomStorage {
    let db = Firestore.firestore()
}
