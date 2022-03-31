//
//  OnlineMetaLevelRepository.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 30/3/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseMetaLevelStorage : ObservableObject {
    @Published var metaLevels: [OnlineMetaLevel] = []
    
    let db = Firestore.firestore()
    
    init() {
        loadOnlineMetaLevels()
    }
    
    func loadOnlineMetaLevels() {
        db.collection("metalevels").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let querySnapshot = querySnapshot {
                self.metaLevels = querySnapshot.documents.compactMap { document in
                    try? document.data(as: OnlineMetaLevel.self)
                }
            }
        }
    }
    
    func upload(metaLevel: MetaLevel) {
        let onlineMetaLevel = OnlineMetaLevel(metaLevel: metaLevel.toPersistable())
        let localChunkNodeStorage = metaLevel.chunkStorage
        let (chunkNodeUrls, chunkNodeFilenames) = localChunkNodeStorage.getAllFiles()
        let chunkNodeUrlObjects = zip(chunkNodeUrls, chunkNodeFilenames).map { URLListObject(url: $0, name: $1 )}
        do {
            let metaLevelRef = db.collection("metalevels").document()
            try metaLevelRef.setData(from: onlineMetaLevel)
            for urlObject in chunkNodeUrlObjects {
                if let chunkNode: PersistableChunkNode = localChunkNodeStorage.loadChunk(identifier: urlObject.name) {
                    let onlineChunkNode = OnlineMetalLevelChunkNode(chunkNode: chunkNode)
                    try metaLevelRef.collection("chunknodes").addDocument(from: onlineChunkNode)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    
    }
}
