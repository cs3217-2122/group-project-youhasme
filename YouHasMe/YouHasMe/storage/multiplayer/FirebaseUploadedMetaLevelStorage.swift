//
//  FirebaseUploadedMetaLevelStorage.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseUploadedMetaLevelStorage: ObservableObject {
    @Published var uploadedMetaLevels: [UploadedMetaLevel] = []
    let collectionPath = "metalevels"
    let db = Firestore.firestore()
    
    init() {
        loadMetaLevels()
    }
    
    func loadMetaLevels() {
        db.collection(collectionPath)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error in loading uploaded meta levels \(error.localizedDescription)")
                    return
                }
                
                if let querySnapshot = querySnapshot {
                    self.uploadedMetaLevels = querySnapshot.documents.compactMap { document in
                        try? document.data(as: UploadedMetaLevel.self)
                    }
                }
            }
    }
    
    func upload(metaLevel: MetaLevel) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let uploadedMetaLevel = UploadedMetaLevel(uploaderId: currentUserId, persistedMetaLevel: metaLevel.toPersistable())
        let localChunkNodeStorage = metaLevel.chunkStorage
        let (chunkNodeUrls, chunkNodeFilenames) = localChunkNodeStorage.getAllFiles()
        let chunkNodeLodables = zip(chunkNodeUrls, chunkNodeFilenames).map { Loadable(url: $0, name: $1 )}
        
        do {
            let metaLevelRef = db.collection(collectionPath).document()
            try metaLevelRef.setData(from: uploadedMetaLevel)
            for loadable in chunkNodeLodables {
                if let chunkNode: PersistableChunkNode = localChunkNodeStorage.loadChunk(identifier: loadable.name) {
                    let onlineChunkNode = UploadedChunkNode(persistedChunkNode: chunkNode)
                    try metaLevelRef.collection("chunknodes").document(chunkNode.identifier.dataString)
                        .setData(from: onlineChunkNode)
                }
             }
         } catch {
             print("Error in uploading metalevel and chunk nodes \(error.localizedDescription)")
         }
    }
}
