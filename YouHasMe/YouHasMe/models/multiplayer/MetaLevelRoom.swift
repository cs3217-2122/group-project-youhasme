//
//  MetaLevelRoom.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct MetaLevelRoom {
    @DocumentID var id: String?
    var persistedMetaLevel: PersistableMetaLevel
    var players: [String]
    var playerPositions: [String: Point] = [:]
}

extension MetaLevelRoom: Codable {
    
}


