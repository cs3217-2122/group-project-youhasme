//
//  OnlineDungeonStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase

struct OnlineDungeonStorage: OnlineDungeonStorageProtocol {
    let db = Firestore.firestore()
    static let collectionPath = "dungeons"
    let onlineLevelStorage = OnlineLevelStorage()

    func upload(dungeon: Dungeon) throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let batch = db.batch()
        let onlineDungeon = OnlineDungeon(uploaderId: currentUserId, persistedDungeon: dungeon.toPersistable())
        let dungeonRef = try uploadOnlineDungeon(onlineDungeon: onlineDungeon, batch: batch)
        _ = try onlineLevelStorage.uploadOnlineLevels(dungeon: dungeon, batch: batch, parentRef: dungeonRef)
        batch.commit()
    }

    private func uploadOnlineDungeon(onlineDungeon: OnlineDungeon, batch: WriteBatch) throws -> DocumentReference {
        let dungeonRef = db.collection(OnlineDungeonStorage.collectionPath).document()
        try batch.setData(from: onlineDungeon, forDocument: dungeonRef)
        return dungeonRef
    }
}
