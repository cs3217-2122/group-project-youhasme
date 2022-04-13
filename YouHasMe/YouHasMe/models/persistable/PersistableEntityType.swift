//
//  PersistableMetaEntityType.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation

struct PersistableEntityType {
    var classification: PersistableClassification
}

extension PersistableEntityType: Codable {}
