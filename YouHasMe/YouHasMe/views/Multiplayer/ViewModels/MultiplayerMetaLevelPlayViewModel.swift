//
//  MultiplayerMetaLevelPlayViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 5/4/22.
//

import Foundation
import Firebase

class MetaLevelRoomListener: ObservableObject {
    @Published var metaLevelRoom: MetaLevelRoom?

    let db = Firestore.firestore()

    func loadMetaLevelRoom(openWorldRoom: OpenWorldRoom) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        guard let openWorldRoomId = openWorldRoom.id else {
            return
        }

        guard let metaLevelRoomId = openWorldRoom.lastPlayerLocations[currentUserId] else {
            return
        }
        let openWorldRoomRef = db.collection(FirebaseOpenWorldRoomStorage.collectionPath).document(openWorldRoomId)
        let metaLevelRoomRef = openWorldRoomRef.collection(FirebaseMetaLevelRoomStorage.collectionPath).document(metaLevelRoomId)
        metaLevelRoomRef.getDocument { querySnapshot, error in
            if let error = error {
                print("Error loading metalevel room: \(error.localizedDescription)")
            }

            if let querySnapshot = querySnapshot {
                let metaLevelRoom = try? querySnapshot.data(as: MetaLevelRoom.self)
                self.metaLevelRoom = metaLevelRoom
            }
        }
    }
}

class MultiplayerMetaLevelViewModel: MetaLevelPlayViewModel {
    let listener: MetaLevelRoomListener

    init(openWorldRoom: OpenWorldRoom) {
        listener = MetaLevelRoomListener()
        listener.loadMetaLevelRoom(openWorldRoom: openWorldRoom)
        super.init(currMetaLevel: MetaLevel())

        listener.$metaLevelRoom
            .sink { [weak self] room in
                guard let self = self else {
                    return
                }
                if let room = room {
                    self.currMetaLevel = MetaLevel.fromPersistable(room.persistedMetaLevel)
                }

            }.store(in: &subscriptions)
    }

}
