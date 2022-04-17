//
//  OnlineDungeonListListener.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase

class OnlineDungeonListListener: ObservableObject {
    @Published var onlineDungeons: [OnlineDungeon] = []
    var handle: ListenerRegistration?

    let db = Firestore.firestore()

    func subscribe() {
        self.handle = db.collection(OnlineDungeonStorage.collectionPath)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Cant retrieve online dungeons \(error.localizedDescription)")
                }

                if let querySnapshot = querySnapshot {
                    self.onlineDungeons = querySnapshot.documents.compactMap { document in
                        try? document.data(as: OnlineDungeon.self)
                    }
                }
            }
    }

    func unsubscribe() {
        handle?.remove()
    }
}
