//
//  UploadedLevel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct UploadedLevel {
    @DocumentID var id: String?
    var uploaderId: String
    var persistedLevel: Level
}

extension UploadedLevel: Codable {
    
}
