//
//  OpenWorldRoom.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct OpenWorldRoom {
    @DocumentID var id: String?
    var name: String
    var joinCode = String(Int.random(in: 1_000...100_000))
    var playerIds: [String] = []
    var entryMetaLevelRoomId: String?
    var lastPlayerLocations: [String: String] = [:]

    mutating func addPlayer(userId: String, metaLevelRoomId: String) {
        guard !playerIds.contains(userId) else {
            return
        }

        guard lastPlayerLocations[userId] == nil else {
            return
        }

        playerIds.append(userId)
        lastPlayerLocations[userId] = metaLevelRoomId
    }
}

extension OpenWorldRoom: Codable, Equatable {

}
