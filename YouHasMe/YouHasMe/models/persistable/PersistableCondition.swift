//
//  PersistableCondition.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
struct PersistableCondition {
    var subject: PersistableConditionEvaluable
    var relation: ConditionRelation
    var object: PersistableConditionEvaluable
}

extension PersistableCondition: Codable {}
