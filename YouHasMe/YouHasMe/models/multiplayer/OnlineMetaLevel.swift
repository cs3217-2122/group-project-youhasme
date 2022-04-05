//
//  OnlineMetaLevel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 3/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct OnlineMetaLevel {
    @DocumentID var id: String?
    var uploaderId: String
    var persistedMetaLevel: PersistableMetaLevel
}

extension OnlineMetaLevel: Codable {

}
