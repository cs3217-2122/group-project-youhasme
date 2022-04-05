//
//  OnlineMetaLevelSelectionViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 4/4/22.
//

import Foundation
import Combine
import Firebase

class OnlineMetaLevelListListener: ObservableObject {
    @Published var onlineMetaLevels: [OnlineMetaLevel] = []

    let db = Firestore.firestore()

    func loadOnlineMetaLevels() {
        db.collection(FirebaseMetaLevelStorage.collectionPath).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error loading online metalevels: \(error.localizedDescription)")
            }

            if let querySnapshot = querySnapshot {
                self.onlineMetaLevels = querySnapshot.documents.compactMap { document in
                    try? document.data(as: OnlineMetaLevel.self)
                }
            }
        }
    }
}

class OnlineMetaLevelSelectionViewModel: ObservableObject {
    @Published var onlineMetaLevels: [OnlineMetaLevel] = []

    private var cancellables = Set<AnyCancellable>()
    let listener = OnlineMetaLevelListListener()

    init() {
        listener.loadOnlineMetaLevels()

        listener.$onlineMetaLevels
            .assign(to: \.onlineMetaLevels, on: self)
            .store(in: &cancellables)
    }

    func createRoom(metaLevel: OnlineMetaLevel) {
        FirebaseOpenWorldRoomStorage.createRoom(using: metaLevel, name: "Trial")
    }
}
