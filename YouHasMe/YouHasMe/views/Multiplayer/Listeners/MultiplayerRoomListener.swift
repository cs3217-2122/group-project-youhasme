//
//  MultiplayerRoomListener.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase

class MultiplayerRoomListener: ObservableObject {
    var roomStorage = MultiplayerRoomStorage()
    let db = Firestore.firestore()
    var handle: ListenerRegistration?
    @Published var multiplayerRoom: MultiplayerRoom?
    @Published var playerStatus: PlayerStatus = .waiting
    @Published var isHost = false
    @Published var joinCode = ""

    func subscribe(roomId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        self.handle = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Couldnt listen to room \(error.localizedDescription)")
                }
                if let querySnapshot = querySnapshot {
                    self.multiplayerRoom = try? querySnapshot.data(as: MultiplayerRoom.self)
                    self.playerStatus = self.multiplayerRoom?.players[currentUserId]?.status ?? .waiting
                    self.isHost = self.multiplayerRoom?.creatorId == currentUserId
                    self.joinCode = self.multiplayerRoom?.joinCode ?? ""
                }
            }
    }

    func unsubscribe() {
        handle?.remove()
    }

    func updateSelectedDungeon(dungeon: OnlineDungeon) {
        guard var roomCopy = multiplayerRoom else {
            return
        }
        roomCopy.dungeon = dungeon
        roomCopy.uploadedDungeonId = dungeon.id
        do {
            try roomStorage.updateRoom(room: roomCopy)
        } catch {
            print("Coudn't update room")
        }
    }

    func createDungeonRoom() {
        guard let room = multiplayerRoom else {
            return
        }
        do {
            try roomStorage.createDungeonRoom(room: room)
        } catch {
            print("Couldn't create dungeon room")
        }

    }
}
