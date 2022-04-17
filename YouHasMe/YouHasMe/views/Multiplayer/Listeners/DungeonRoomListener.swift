//
//  DungeonRoomListener.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase

class DungeonRoomListener: ObservableObject {
    var roomId: String
    var dungeonRoomId: String
    var handle: ListenerRegistration?
    let db = Firestore.firestore()
    let storage = MultiplayerRoomStorage()
    @Published var dungeonRoom: DungeonRoom?
    @Published var playerPos = Point.zero
    @Published var playerNumAssignment: [String: Int] = [:]
    @Published var playerNum: Int?

    init(roomId: String, dungeonRoomId: String) {
        self.roomId = roomId
        self.dungeonRoomId = dungeonRoomId

    }

    func isCurrentPlayer(playerId: String) -> Bool {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        return currentUserId == playerId
    }

    func subscribe() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        self.handle = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(DungeonRoomStorage.collectionPath).document(dungeonRoomId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Couldnt observe dungeon room \(error.localizedDescription)")
                }
                if let querySnapshot = querySnapshot {
                    self.dungeonRoom = try? querySnapshot.data(as: DungeonRoom.self)
                    self.playerPos = self.dungeonRoom?.playerLocations[currentUserId] ?? Point.zero
                    self.playerNumAssignment = self.dungeonRoom?.players ?? [:]
                    self.playerNum = self.playerNumAssignment[currentUserId]
                }

            }
    }

    func updatePosition(pos: Point, playerNum: Int) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        guard var dungeonRoomCopy = self.dungeonRoom else {
            return
        }

        if playerNum == 0 || playerNum == self.playerNumAssignment[currentUserId] {
            dungeonRoomCopy.playerLocations[currentUserId] = pos
            do {
                try storage.updateDungeonRoom(dungeonRoom: dungeonRoomCopy, roomId: self.roomId)
            } catch {
                print("Unable to update position")
            }
        }
    }

    func unsubscribe() {
        self.handle?.remove()
    }
}
