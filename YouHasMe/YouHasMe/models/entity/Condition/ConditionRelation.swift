//
//  ConditionRelation.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
enum ConditionRelation: String {
    case eq = "="
    case geq = ">="
    case leq = "<="
    case lt = "<"
    case gt = ">"
}

extension ConditionRelation: Codable {}

extension ConditionRelation: Hashable {}

extension ConditionRelation: CustomStringConvertible {
    var description: String {
        rawValue
    }
}

extension ConditionRelation {
    func evaluate(lhs: Int, rhs: Int) -> Bool {
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
