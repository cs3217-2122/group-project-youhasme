//
//  FirebaseMetaLevelStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation
import Firebase

struct FirebaseLevelStorage {
    static let collectionPath = "levels"
    static let db = Firestore.firestore()
    static func uploadLevels(from chunkNode: ChunkNode, referTo docRef: DocumentReference, by userId: String, with batch: WriteBatch) -> Bool {
        let levelLoadables = getLevelLoadables(from: chunkNode)
        let levelStorage = LevelStorage()
        for loadable in levelLoadables {
            guard let level = levelStorage.loadLevel(name: loadable.name) else {
                return false
            }
            let onlineLevel = OnlineLevel(persistedLevel: level, uploaderId: userId, metaLevelId: docRef.documentID)
            let levelRef = docRef.collection(collectionPath).document()
            do {
                try batch.setData(from: onlineLevel, forDocument: levelRef)
            } catch {
                print("Error uploading level \(error.localizedDescription)")
                return false
            }
        }
        return true
    }

    private static func getLevelLoadables(from chunkNode: ChunkNode) -> [Loadable] {
        let tiles = chunkNode.chunkTiles.flatMap { $0 }
        var levelLoadables: [Loadable] = []
        for tile in tiles {
            for entity in tile.metaEntities {
                switch entity {
                case .level(let loadable, _):
                    if let loadable = loadable {
                        levelLoadables.append(loadable)
                    }
                default:
                    continue
                }
            }
        }
        return levelLoadables
    }
}

struct FirebaseChunkNodeStorage {
    static let collectionPath = "chunknodes"
    static let db = Firestore.firestore()

    static func copyOverChunkNodes(chunkNodes: [OnlineChunkNode], referTo docRef: DocumentReference, with batch: WriteBatch) -> Bool {
        for chunkNode in chunkNodes {
            let identifier = chunkNode.persistedChunkNode.identifier
            let newChunkNodeRef = docRef.collection(collectionPath).document(identifier.dataString)
            do {
                try batch.setData(from: chunkNode, forDocument: newChunkNodeRef)
            } catch {
                print("Error copying over chunk node: \(error.localizedDescription)")
                return false
            }
        }
        return true
    }

    static func uploadChunkNodes(from metaLevel: MetaLevel, referTo docRef: DocumentReference, by userId: String, with batch: WriteBatch) -> Bool {
        let localChunkNodeStorage = metaLevel.chunkStorage
        let (urls, names) = localChunkNodeStorage.getAllFiles()
        let chunkNodeLodables = zip(urls, names).map { Loadable(url: $0, name: $1) }
        for chunkNodeLodable in chunkNodeLodables {
            guard let chunkNode: ChunkNode = localChunkNodeStorage.loadChunk(identifier: chunkNodeLodable.name) else {
                return false
            }
            let identifier = chunkNode.identifier
            let chunkNodeRef = docRef.collection(collectionPath).document(identifier.dataString)
            let onlineChunkNode = OnlineChunkNode(persistedChunkNode: chunkNode.toPersistable(), metaLevelId: docRef.documentID, uploaderId: userId)
            do {
                try batch.setData(from: onlineChunkNode, forDocument: chunkNodeRef)
            } catch {
                print("Error uploading chunk nodes \(error.localizedDescription)")
                return false
            }

            let success = FirebaseLevelStorage.uploadLevels(from: chunkNode, referTo: docRef, by: userId, with: batch)
            if !success {
                return false
            }
        }
        return true
    }

}

struct FirebaseMetaLevelStorage {
    static let db = Firestore.firestore()
    static let collectionPath = "metalevels"
    static let localStorage = MetaLevelStorage()
    static func uploadMetaLevel(metaLevelLoadable: Loadable) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        guard let metaLevel = localStorage.loadMetaLevel(name: metaLevelLoadable.name) else {
            print("No such metalevel")
            return
        }

        let batch = db.batch()
        let metaLevelRef = db.collection(collectionPath).document()
        let onlineMetaLevel = OnlineMetaLevel(uploaderId: currentUserId, persistedMetaLevel: metaLevel.toPersistable())

        do {
            try batch.setData(from: onlineMetaLevel, forDocument: metaLevelRef)
        } catch {
            print("Error in uploading meta level \(error.localizedDescription)")
            return
        }

        let chunkNodeSuccess = FirebaseChunkNodeStorage.uploadChunkNodes(from: metaLevel, referTo: metaLevelRef, by: currentUserId, with: batch)

        if chunkNodeSuccess {
            batch.commit()
        }
    }
}
