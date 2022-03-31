//
//  User.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 30/3/22.
//

import Foundation
import FirebaseFirestoreSwift

// Not used for now
struct User {
    @DocumentID var documentId : String?
    let id : String
    let displayName: String
}

extension User: Codable {
    
}
