//
//  FirebaseOpenWorldRoomStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation
import Firebase

struct FirebaseLevelRoomStorage {
    static let db = Firestore.firestore()
    static let collectionPath = "levelrooms"

    static func joinRoom(code: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection(collectionPath).whereField("joinCode", isEqualTo: code)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error joining room \(error.localizedDescription)")
                }

                if let querySnapshot = querySnapshot {
                    let documents = querySnapshot.documents
                    guard documents.count == 1 else {
                        return
                    }
                    if let firstDocument = documents.first {
                        let documentId = firstDocument.documentID
                        addPlayerToRoom(id: documentId)
                    }
                }
            }
    }

    static func addPlayerToRoom(id: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let roomRef = db.collection(collectionPath).document(id)
        db.runTransaction({ transaction, _ -> Any? in
            let room = try? transaction.getDocument(roomRef).data(as: LevelRoom.self)
            if var room = room {
                let numPlayers = room.playerIds.count
                room.playerIds.append(currentUserId)
                room.playerNumAssignment[currentUserId] = numPlayers + 1
                _ = try? transaction.setData(from: room, forDocument: roomRef, merge: true)
            }
            return nil
        }) { _, _ in
        }
    }

    static func createLevelRoom(using level: Level) -> String {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return ""
        }

        let levelRoom = LevelRoom(persistedLevel: level, playerIds: [currentUserId], playerNumAssignment: [currentUserId: 1])

        let levelRoomRef = db.collection(collectionPath).document()
        try? levelRoomRef.setData(from: levelRoom)
        return levelRoomRef.documentID
    }
}

struct FirebaseMetaLevelRoomStorage {
    static let db = Firestore.firestore()
    static let collectionPath = "metalevelrooms"

    static func createMetaLevelRoom(using metaLevel: OnlineMetaLevel, referTo docRef: DocumentReference, entryRoom: Bool = false, userId: String) {
        guard let metaLevelId = metaLevel.id else {
            return
        }
        let batch = db.batch()
        let metaLevelRef = db.collection(FirebaseMetaLevelStorage.collectionPath).document(metaLevelId)
        metaLevelRef.collection(FirebaseChunkNodeStorage.collectionPath).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting chunk nodes: \(error.localizedDescription)")
                return
            }

            if let querySnapshot = querySnapshot {
                let chunkNodeDocuments = querySnapshot.documents
                let chunkNodes = chunkNodeDocuments.compactMap { document in
                    try? document.data(as: OnlineChunkNode.self)
                }

                let metaLevelRoomRef = docRef.collection(collectionPath).document()
                if entryRoom {
                    batch.updateData([
                        "entryMetaLevelRoomId": metaLevelRoomRef.documentID,
                        "playerIds": FieldValue.arrayUnion([userId])], forDocument: docRef)
                }

                batch.updateData(["lastPlayerLocations.\(userId)": metaLevelRoomRef.documentID], forDocument: docRef)

                let chunkNodeSuccess = FirebaseChunkNodeStorage
                    .copyOverChunkNodes(chunkNodes: chunkNodes, referTo: metaLevelRoomRef, with: batch)

                if chunkNodeSuccess {
                    batch.commit()
                }
            }
        }
    }
}

struct FirebaseOpenWorldRoomStorage {
    static let db = Firestore.firestore()
    static let collectionPath = "openworlds"

    static func joinRoom(ref: DocumentReference) {

    }

    static func createRoom(using metaLevel: OnlineMetaLevel, name: String) {
        guard metaLevel.id != nil else {
            return
        }

        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let openWorldRef = db.collection(collectionPath).document()
        let openWorldRoom = OpenWorldRoom(name: name)
        do {
            try openWorldRef.setData(from: openWorldRoom)
            FirebaseMetaLevelRoomStorage.createMetaLevelRoom(using: metaLevel, referTo: openWorldRef, entryRoom: true, userId: currentUserId)
        } catch {
            print("Open world room couldnt be created: \(error.localizedDescription)")
        }
    }
}
