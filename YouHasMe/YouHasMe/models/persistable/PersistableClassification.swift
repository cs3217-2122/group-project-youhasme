//
//  PersistableClassification.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
enum PersistableClassification {
    case noun(Noun)
    case verb(Verb)
    case connective(Connective)
    case property(Property)
    case nounInstance(Noun)
    case conditionRelation(ConditionRelation)
    case conditionEvaluable(PersistableConditionEvaluable)
}

extension PersistableClassification: Codable {}
