//
//  OnlineLevel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 15/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct OnlineLevel {
    @DocumentID var id: String?
    var persistedLevel: PersistableLevel
}

extension OnlineLevel: Codable {
    
}
