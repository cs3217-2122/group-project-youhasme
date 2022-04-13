//
//  MetaLevelRoom.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct MetaLevelRoom {
    @DocumentID var id: String?
    var persistedMetaLevel: PersistableMetaLevel
    var playerIds: [String] = []
    var playerPositions: [String: Point] = [:]
}

extension MetaLevelRoom: Codable {

}