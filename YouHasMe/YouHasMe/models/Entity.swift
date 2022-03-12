//
//  Entity.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import Foundation
enum EntityType: Hashable {
    case noun(Noun)
    case verb(Verb)
    case connective(Connective)
    case property(Property)
    case nounInstance(Noun)
}

extension EntityType {
    var isMetaData: Bool {
        if case .nounInstance(_) = self else {
            return false
        }
        return true
    }
}

enum Connective: Hashable {
    case and
}

enum Verb: Hashable {
    case vIs
    case vHas
}

enum Noun: Hashable {
    case baba
    case wall
    case flag
    case skull
}

enum Property: Hashable {
    case you
    case win
    case defeat
    case block
    case equalTo(Noun)
}


class Entity {
    var classification: EntityType
    var rules: [Rule] = []
    
    fileprivate init(classification: EntityType) {
        self.classification = classification
    }
}
