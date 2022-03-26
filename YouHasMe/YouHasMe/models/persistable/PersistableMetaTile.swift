//
//  PersistableMetaTile.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 23/3/22.
//

import Foundation

struct PersistableMetaTile {
    var metaEntities: [MetaEntityType]
}

extension PersistableMetaTile: Codable {}
