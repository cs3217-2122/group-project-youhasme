//
//  OnlineDungeon.swift
//  YouHasMe
//
//

import Foundation
import FirebaseFirestoreSwift

struct OnlineDungeon {
    @DocumentID var id: String?
    var uploaderId: String
    var persistedDungeon: PersistableDungeon
}

extension OnlineDungeon: Codable, Identifiable {
    
}
