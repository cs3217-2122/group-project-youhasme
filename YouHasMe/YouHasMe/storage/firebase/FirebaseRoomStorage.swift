//
//  FirebaseRoomStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 31/3/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// TODO: Refactor from Callbacks to Combine maybe
class FirebaseRoomStorage : ObservableObject {
    @Published var rooms: [MetaLevelRoom] = []
    
    let db = Firestore.firestore()
    
    init() {
        loadRooms()
    }
    
    func loadRooms() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        print("User Id \(currentUserId)")
        db.collection("rooms").whereField("players", arrayContains: currentUserId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let querySnapshot = querySnapshot {
                    self.rooms = querySnapshot.documents.compactMap { document in
                        try? document.data(as: MetaLevelRoom.self)
                    }
                }
            }
    }
    
    func joinRoom(inputCode: Int) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("rooms").whereField("code", isEqualTo: inputCode)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Join Room Error \(err)")
                }
                
                if let querySnapshot = querySnapshot, querySnapshot.documents.count == 1 {
                    if let roomRef = querySnapshot.documents.first {
                        let documentId = roomRef.documentID
                        self.db.collection("rooms").document(documentId)
                            .updateData(
                                ["players": FieldValue.arrayUnion([currentUserId])]
                            )
                                         
                    }
                }
            }
    }
    
    func createRoom(from onlineMetaLevel: OnlineMetaLevel) {
        guard let metaLevelDocumentId = onlineMetaLevel.id else {
            return
        }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let persistableMetaLevel = onlineMetaLevel.metaLevel
        var room = MetaLevelRoom(metaLevel: persistableMetaLevel)
        // TODO: Add code for positions to add users in
        room.addPlayer(id: currentUserId, position: Point.zero)
        
        let roomRef = db.collection("rooms").document()
        do {
            try roomRef.setData(from: room)
            let metaLevelRef = db.collection("metalevels").document(metaLevelDocumentId)
            let chunkNodesRef = metaLevelRef.collection("chunknodes")
            chunkNodesRef.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting chunknodes: \(err)")
                }
                if let querySnapshot = querySnapshot {
                    let onlineChunkNodes = querySnapshot.documents.compactMap { document in
                        try? document.data(as: OnlineMetalLevelChunkNode.self)
                    }

                    for onlineChunkNode in onlineChunkNodes {
                        let newOnlineChunkNode = OnlineMetalLevelChunkNode(chunkNode: onlineChunkNode.chunkNode)
                        do {
                            try roomRef.collection("chunknodes").addDocument(from: newOnlineChunkNode)
                        }
                        catch {
                            print("Couldn't add chunk node to room: \(error.localizedDescription)")
                        }
                        
                    }
                }
            }
        }
        catch {
            print("Error creating room: \(error.localizedDescription)")
        }
    }
}
