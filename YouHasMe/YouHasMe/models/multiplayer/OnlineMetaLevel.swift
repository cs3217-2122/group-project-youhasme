//
//  OnlineMetaLevel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 30/3/22.
//

import Foundation
import FirebaseFirestoreSwift

struct OnlineMetaLevel {
    @DocumentID var id : String?
    let metaLevel: PersistableMetaLevel
}

extension OnlineMetaLevel: Codable {
    
}
