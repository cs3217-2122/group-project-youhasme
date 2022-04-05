//
//  LevelMove.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct LevelMove {
    @DocumentID var id: String?
    var player: String
    var move: UpdateAction
    @ServerTimestamp var timestamp: Timestamp?
}

extension LevelMove: Codable {

}
