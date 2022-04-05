//
//  OnlineChunkNode.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation

struct OnlineChunkNode {
    var persistedChunkNode: PersistableChunkNode
    var metaLevelId: String
    var uploaderId: String
}

extension OnlineChunkNode: Codable {

}
