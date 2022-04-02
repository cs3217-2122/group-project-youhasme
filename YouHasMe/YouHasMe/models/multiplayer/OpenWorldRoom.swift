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
    var joinCode: String
    var playerIds: [String]
}



extension OpenWorldRoom: Codable {
    
}
