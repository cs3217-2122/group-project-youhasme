//
//  LevelRoomStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase

struct LevelRoomStorage {
    let db = Firestore.firestore()
    static let collectionPath = "level"

    func createLevelRoom(level: PersistableLevel, parentRef: DocumentReference) {
        let levelId = level.id.dataString
        let levelRoomRef = parentRef.collection(LevelRoomStorage.collectionPath).document(levelId)
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
    }

    func updateLevelRoom(levelRoom: LevelRoom, parentRef: DocumentReference) throws {
        let levelRoomId = levelRoom.persistableLevel.id.dataString
        let levelRoomRef = parentRef.collection(LevelRoomStorage.collectionPath).document(levelRoomId)
        try levelRoomRef.setData(from: levelRoom)
    }
}
