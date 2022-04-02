//
//  OpenWorldRoom.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct OpenWorldRoom {
    @DocumentID var id : String?
    var name: String
    var joinCode: String = UUID().uuidString
    var playerIds: [String]
    var entryMetaLevelDocumentId: String
    // Mapping from Player Ids to MetaLevelRoom Ids
    var lastKnownPlayerLocations: [String: String] = [:]
}



extension OpenWorldRoom: Codable {
    
}
