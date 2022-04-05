//
//  RoomListViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 4/4/22.
//

import Foundation
import Firebase
import Combine

class RoomListListener: ObservableObject {
    @Published var rooms: [OpenWorldRoom] = []
    var handle: ListenerRegistration?

    let db = Firestore.firestore()

    func loadRooms() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        self.handle = db.collection(FirebaseOpenWorldRoomStorage.collectionPath)
            .whereField("playerIds", arrayContains: currentUserId)
            .addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Couldn't load open world rooms: \(error.localizedDescription)")
            }

            if let querySnapshot = querySnapshot {
                self.rooms = querySnapshot.documents.compactMap { document in
                    try? document.data(as: OpenWorldRoom.self)
                }
            }
            }
    }

    func unsubscribe() {
        handle?.remove()
    }
}

class RoomListViewModel: ObservableObject {
    @Published var rooms: [OpenWorldRoom] = []
    var listener = RoomListListener()

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
