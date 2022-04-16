//
//  OnlineDungeonListViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase
import Combine

class OnlineDungeonListListener: ObservableObject {
    @Published var onlineDungeons: [OnlineDungeon] = []
    var handle: ListenerRegistration?

    let db = Firestore.firestore()

    func subscribe() {
        self.handle = db.collection(OnlineDungeonStorage.dungeonCollectionPath)
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

class OnlineDungeonListViewModel: ObservableObject {
    var listener = OnlineDungeonListListener()
    @Published var onlineDungeons: [OnlineDungeon] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        listener.subscribe()
        listener.$onlineDungeons
            .assign(to: \.onlineDungeons, on: self)
            .store(in: &cancellables)
    }

    deinit {
        listener.unsubscribe()
    }
}
