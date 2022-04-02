//
//  PersistableMetaEntityType.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
enum PersistableMetaEntityType {
    case blocking
    case nonBlocking
    case space
    case level(levelLoadable: Loadable? = nil, unlockCondition: PersistableCondition? = nil)
    case travel(metaLevelLoadable: Loadable? = nil, unlockCondition: PersistableCondition? = nil)
    // TODO: Perhaps the message can be associated with a user
    case message(text: String? = nil)
}

extension PersistableMetaEntityType: Codable {}
