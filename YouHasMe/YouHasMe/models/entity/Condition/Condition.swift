//
//  Condition.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import Foundation

struct AnyNamedKeyPath: Identifiable {
    var id: String
    var keyPath: AnyKeyPath
}

extension AnyNamedKeyPath: CustomStringConvertible {
    var description: String {
        id
    }
}

struct NamedKeyPath<PathRoot, Value>: Identifiable {
    var id: String
    var keyPath: KeyPath<PathRoot, Value>

    func eraseToAnyKeyPath() -> AnyNamedKeyPath {
        AnyNamedKeyPath(id: id, keyPath: keyPath)
    }
}

extension NamedKeyPath {
    func toPersistable() -> PersistableNamedKeyPath {
        PersistableNamedKeyPath(id: id)
    }
}

extension NamedKeyPath: CustomStringConvertible {
    var description: String {
        id
    }
}

extension NamedKeyPath: Hashable {}

struct PersistableNamedKeyPath: Codable {
    var id: String
}

protocol KeyPathExposable {
    typealias Identifier = String
    associatedtype PathRoot
    static var exposedNumericKeyPathsMap: [Identifier: KeyPath<PathRoot, Int>] { get }
    func evaluate(given keyPath: NamedKeyPath<PathRoot, Int>) -> Int
}

extension KeyPathExposable {
    static func getNamedKeyPath(given id: Identifier) -> NamedKeyPath<PathRoot, Int>? {
        guard let keyPath = exposedNumericKeyPathsMap[id] else {
            return nil
        }
        return NamedKeyPath(id: id, keyPath: keyPath)
    }

    static var namedKeyPaths: [NamedKeyPath<PathRoot, Int>] {
        exposedNumericKeyPathsMap.map { NamedKeyPath(id: $0, keyPath: $1) }
    }

    static var typeErasedNamedKeyPaths: [AnyNamedKeyPath] {
        namedKeyPaths.map { $0.eraseToAnyKeyPath() }
    }

    static func keyPathfromPersistable(
        _ persistableNamedKeyPath: PersistableNamedKeyPath
    ) -> NamedKeyPath<PathRoot, Int>? {
        let id = persistableNamedKeyPath.id
        guard let keyPath = exposedNumericKeyPathsMap[id] else {
            return nil
        }
        return NamedKeyPath(id: id, keyPath: keyPath)
    }
}





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
