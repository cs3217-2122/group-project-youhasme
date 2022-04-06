//
//  Condition.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import Foundation
struct Condition {
    var subject: ConditionEvaluable
    var relation: ConditionRelation
    var object: ConditionEvaluable
    init(subject: ConditionEvaluable, relation: ConditionRelation, object: ConditionEvaluable) {
        self.subject = subject
        self.relation = relation
        self.object = object
    }

    func isConditionMet() -> Bool {
        guard let lhsValue = subject.getValue(), let rhsValue = object.getValue() else {
            return true
        }

        return relation.evaluate(lhs: lhsValue, rhs: rhsValue)
    }
}

extension Condition: Hashable {}

extension Condition: CustomStringConvertible {
    var description: String {
        """
        \(subject.description) \(relation.description) \(object.description)
        """
    }
}

// MARK: Persistable
extension Condition {
    func toPersistable() -> PersistableCondition {
        PersistableCondition(
            subject: subject.toPersistable(),
            relation: relation,
            object: object.toPersistable()
        )
    }

    static func fromPersistable(_ persistableCondition: PersistableCondition) -> Condition {
        Condition(
            subject: ConditionEvaluable.fromPersistable(persistableCondition.subject),
            relation: persistableCondition.relation,
            object: ConditionEvaluable.fromPersistable(persistableCondition.object)
        )
    }
}
