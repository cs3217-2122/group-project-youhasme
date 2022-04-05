//
//  LevelRoomViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 5/4/22.
//

import Foundation
import Firebase
import Combine

class LevelRoomListListener: ObservableObject {
    @Published var rooms: [LevelRoom] = []
    var handle: ListenerRegistration?

    let db = Firestore.firestore()

    func loadRooms() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        self.handle = db.collection(FirebaseLevelRoomStorage.collectionPath)
            .whereField("playerIds", arrayContains: currentUserId)
            .addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Couldn't load open world rooms: \(error.localizedDescription)")
            }

            if let querySnapshot = querySnapshot {
                self.rooms = querySnapshot.documents.compactMap { document in
                    try? document.data(as: LevelRoom.self)
                }
            }
            }
    }

    func unsubscribe() {
        handle?.remove()
    }
}

class LevelRoomViewModel: ObservableObject {
    @Published var rooms: [LevelRoom] = []
    var listener = LevelRoomListListener()

    private var cancellables = Set<AnyCancellable>()

    init() {
//        print("INIT")
        listener.loadRooms()
        listener.$rooms
            .assign(to: \.rooms, on: self)
            .store(in: &cancellables)
    }

//    deinit {
//        print("DEINIT")
//        listener.unsubscribe()
//    }
 }
