//
//  UploadedChunkNode.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation

struct UploadedChunkNode {
    var uploaderID: String
    var persistedChunkNode: PersistableChunkNode
}


extension UploadedChunkNode: Codable {
    
}
