//
//  LevelRoomListener.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase

class LevelRoomListener: ObservableObject {
    var roomId: String
    var dungeonRoomId: String
    var point: Point
    var roomHandle: ListenerRegistration?
    var moveHandle: ListenerRegistration?
    var storage = MultiplayerRoomStorage()
    let db = Firestore.firestore()
    @Published var levelRoom: LevelRoom?
    @Published var levelMoves: [LevelMove] = []
    
    init(roomId: String, dungeonRoomId: String, point: Point) {
        self.roomId = roomId
        self.dungeonRoomId = dungeonRoomId
        self.point = point
        storage.createLevelRoom(roomId: roomId, dungeonRoomId: dungeonRoomId, levelId: point.dataString)
    }
    
    func subscribe() {
        self.roomHandle = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(DungeonRoomStorage.collectionPath).document(dungeonRoomId)
            .collection(LevelRoomStorage.collectionPath).document(point.dataString)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Couldnt observe level room \(error.localizedDescription)")
                }
                if let querySnapshot = querySnapshot {
                    self.levelRoom = try? querySnapshot.data(as: LevelRoom.self)
                }
            }

        self.moveHandle = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(DungeonRoomStorage.collectionPath).document(dungeonRoomId)
            .collection(LevelRoomStorage.collectionPath).document(point.dataString)
            .collection("moves")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting moves: \(error.localizedDescription)")
                }

                if let querySnapshot = querySnapshot {
                    var isPendingWrite = false
                    let levelMoves: [LevelMove] = querySnapshot.documents.compactMap { document in
                        if document.metadata.hasPendingWrites  {
                            isPendingWrite = true
                            return nil
                        } else {
                            return try? document.data(as: LevelMove.self)
                        }
                    }
                    
                    if !isPendingWrite {
                        self.levelMoves = levelMoves
                    }
                }
            }
    }
    
    func incrementWinCount() {
        guard var levelRoomCopy = self.levelRoom else {
            return
        }
        
        levelRoomCopy.winCount += 1
        do {
            try storage.updateLevelRoom(roomId: self.roomId, dungeonRoomId: self.dungeonRoomId, levelRoom: levelRoomCopy)
        } catch {
            print("couldnt update win count")
        }
        
    }
    
    func sendAction(actionType: ActionType) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let move = LevelMove(playerId: currentUserId, move: actionType)
        let moveRef = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(DungeonRoomStorage.collectionPath).document(dungeonRoomId)
            .collection(LevelRoomStorage.collectionPath).document(point.dataString)
            .collection("moves").document()
        try? moveRef.setData(from: move)
    }

    func unsubscribe() {
        self.roomHandle?.remove()
        self.moveHandle?.remove()
    }
}
