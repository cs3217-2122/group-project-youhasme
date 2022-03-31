//
//  OnlineChunkNode.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 30/3/22.
//

import Foundation
import FirebaseFirestoreSwift

struct OnlineMetalLevelChunkNode {
    @DocumentID var documentId : String?
    let chunkNode: PersistableChunkNode
}

extension OnlineMetalLevelChunkNode: Codable {
    
}
