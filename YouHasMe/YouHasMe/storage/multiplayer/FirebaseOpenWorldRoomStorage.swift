//
//  FirebaseOpenWorldRoomStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseOpenWorldRoomStorage: ObservableObject {
    @Published var rooms: [OpenWorldRoom] = []
    let collectionPath = "openworldrooms"
    let db = Firestore.firestore()
    
    init() {
        loadRooms()
    }
    
    func loadRooms() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection(collectionPath).whereField("players", arrayContains: currentUserId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error in loading rooms \(error.localizedDescription)")
                    return
                }
                
                if let querySnapshot = querySnapshot {
                    self.rooms = querySnapshot.documents.compactMap { document in
                        try? document.data(as: OpenWorldRoom.self)
                    }
                }
            }
    }
    
    func joinRoom(joinCode: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection(collectionPath)
            .whereField("joinCode", isEqualTo: joinCode)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error joining room: \(error.localizedDescription)")
                }
                
                if let querySnapshot = querySnapshot, querySnapshot.documents.count == 1 {
                    if let openWorldRoomRef = querySnapshot.documents.first {
                        do {
                            var openWorldRoom = try openWorldRoomRef.data(as: OpenWorldRoom.self)
                            let openWorldDocumentId = openWorldRoomRef.documentID
                            let entryMetaLevelId = openWorldRoom.entryMetaLevelDocumentId
                            openWorldRoom.playerIds.append(currentUserId)
                            openWorldRoom.lastKnownPlayerLocations[currentUserId] = openWorldRoom.entryMetaLevelDocumentId
                            
                            try self.db.collection(self.collectionPath).document(openWorldDocumentId)
                                .setData(from: openWorldRoom)
                            
                            
                            self.db.collection(self.collectionPath)
                                .document(openWorldDocumentId)
                                .collection("metaLevelRooms")
                                .document(entryMetaLevelId)
                                .updateData(
                                    ["players": FieldValue.arrayUnion([currentUserId])])
                            
                            self.db.collection(self.collectionPath)
                                .document(openWorldDocumentId)
                                .collection("metaLevelRooms")
                                .document(entryMetaLevelId)
                                .setData(["playerPositions.\(currentUserId)": Point.zero])
                            
                        } catch {
                            print("Error decoding Open World \(error.localizedDescription)")
                        }
                        
                    }
                }
                
            }
        
    }
    
    // TODO: Refactor to split into smaller functions
    func createRoom(from uploadedMetaLevel: UploadedMetaLevel, name: String) {
        guard let metaLevelDocumentId = uploadedMetaLevel.id else {
             return
         }
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
             return
         }

        let persistableMetaLevel = uploadedMetaLevel.persistedMetaLevel
       
        var metaLevelRoom = MetaLevelRoom(persistedMetaLevel: persistableMetaLevel, players: [currentUserId])
        // TODO: Add code for positions to add users in
        metaLevelRoom.playerPositions[currentUserId] = Point.zero
        let openWorldRoomRef = db.collection(collectionPath).document()
        let metaLevelRef = db.collection("metalevels").document(metaLevelDocumentId)
        
         do {
             
             let metaLevelRoomRef = openWorldRoomRef.collection("metaLevelRooms").document()
             var openWorldRoom = OpenWorldRoom(name: name, playerIds: [currentUserId], entryMetaLevelDocumentId: metaLevelRoomRef.documentID)
             openWorldRoom.lastKnownPlayerLocations[currentUserId] = metaLevelRoomRef.documentID
             
             try openWorldRoomRef.setData(from: openWorldRoom)
             try metaLevelRoomRef.setData(from: metaLevelRoom)
             
             let chunkNodesRef = metaLevelRef.collection("chunknodes")
             chunkNodesRef.getDocuments() { (querySnapshot, err) in
                 if let err = err {
                     print("Error getting chunknodes: \(err.localizedDescription)")
                 }
                 if let querySnapshot = querySnapshot {
                     let uploadedChunkNodes = querySnapshot.documents.compactMap { document in
                         try? document.data(as: UploadedChunkNode.self)
                     }

                     for uploadedChunkNode in uploadedChunkNodes {
                         let newUploadedChunkNode = UploadedChunkNode(persistedChunkNode: uploadedChunkNode.persistedChunkNode)
                         do {
                             try metaLevelRoomRef.collection("chunknodes").document(uploadedChunkNode.persistedChunkNode.identifier.dataString)
                                 .setData(from: newUploadedChunkNode)
                         } catch {
                             print("Couldn't add chunk node to meta level room: \(error.localizedDescription)")
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
