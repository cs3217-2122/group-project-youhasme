//
//  Condition.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import Foundation

protocol AbstractConditionSubject: Codable {
    var value: Double { get }
}

struct ConditionSubject: AbstractConditionSubject {
    var value: Double
}

enum ConditionRelation {
    case eq
    case geq
    case leq
    case lt
    case gt
}

extension ConditionRelation: Codable {}

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

final class Condition {
    var subject: ConditionSubject
    var relation: ConditionRelation
    var value: Double
    init(subject: ConditionSubject, relation: ConditionRelation, value: Double) {
        self.subject = subject
        self.relation = relation
        self.value = value
    }

    func isConditionMet() -> Bool {
        relation.evaluate(lhs: subject.value, rhs: value)
    }
}

extension Condition: Codable {}

extension Condition: Equatable {
    static func == (lhs: Condition, rhs: Condition) -> Bool {
        lhs === rhs
    }
}
