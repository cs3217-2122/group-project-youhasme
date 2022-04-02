//
//  UploadedMetaLevel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct UploadedMetaLevel {
    @DocumentID var id: String?
    var uploaderId : String
    var persistedMetaLevel: PersistableMetaLevel
}

extension UploadedMetaLevel: Codable {
    
}
