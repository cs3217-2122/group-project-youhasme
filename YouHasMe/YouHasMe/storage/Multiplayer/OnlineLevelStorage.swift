//
//  OnlineLevelStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase

struct OnlineLevelStorage {
    let db = Firestore.firestore()
    static let collectionPath = "levels"
    
    private func getOnlineLevels(dungeon: Dungeon) -> [OnlineLevel] {
        let levelStorage = dungeon.levelStorage
        let levelLodables = levelStorage.getAllLoadables()
        let onlineLevels: [OnlineLevel] = levelLodables.compactMap {  loadable in
            guard let persistedLevel: PersistableLevel = levelStorage.loadLevel(loadable.name) else {
                return nil
            }
            return OnlineLevel(persistedLevel: persistedLevel)
        }
        return onlineLevels
    }
    
    func uploadOnlineLevels(dungeon: Dungeon, batch: WriteBatch, parentRef: DocumentReference) throws -> [DocumentReference] {
        let onlineLevels = getOnlineLevels(dungeon: dungeon)
        var levelRefs: [DocumentReference] = []
        for onlineLevel in onlineLevels {
            let id = onlineLevel.persistedLevel.id.dataString
            let levelRef = parentRef.collection(OnlineLevelStorage.collectionPath).document(id)
            try batch.setData(from: onlineLevel, forDocument: levelRef)
            levelRefs.append(levelRef)
        }
        return levelRefs
    }
}
