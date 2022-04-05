//
//  LevelRoom.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct LevelRoom {
    @DocumentID var id: String?
    var joinCode = String(Int.random(in: 1_000...100_000))
    var persistedLevel: Level
    var playerIds: [String]
    var playerNumAssignment: [String: Int]
 }

extension LevelRoom: Codable {

}
