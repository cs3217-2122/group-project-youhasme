//
//  OnlineLevel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct OnlineLevel {
    @DocumentID var id: String?
    var persistedLevel: Level
    var uploaderId: String
    var metaLevelId: String
}

extension OnlineLevel: Codable {

}
