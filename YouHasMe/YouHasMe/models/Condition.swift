//
//  Condition.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import Foundation

protocol ConditionSubject {
    var value: Double { get }
}

enum ConditionRelation {
    case eq
    case geq
    case leq
    case lt
    case gt
}

extension ConditionRelation {
    func evaluate(lhs: Double, rhs: Double) -> Bool {
        switch self {
        case .eq:
            return lhs == rhs
        case .geq:
            return lhs >= rhs
        case .leq:
            return lhs <= rhs
        case .lt:
            return lhs < rhs
        case .gt:
            return lhs > rhs
        }
    }
}

struct Condition {
    var subject: ConditionSubject
    var relation: ConditionRelation
    var value: Double
    init<T: ConditionSubject>(subject: T, relation: ConditionRelation, value: Double) {
        self.subject = subject
        self.relation = relation
        self.value = value
    }
    
    func isConditionMet() -> Bool {
        relation.evaluate(lhs: subject.value, rhs: value)
    }
}
