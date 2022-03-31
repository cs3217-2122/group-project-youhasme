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

enum ConditionEvaluable {
    case metaLevel(loadable: Loadable, evaluatingKeyPath: NamedKeyPath<MetaLevel, Int>)
    case level(loadable: Loadable, evaluatingKeyPath: NamedKeyPath<Level, Int>)
    case player
    case numericLiteral(Int)
}

extension ConditionEvaluable: Hashable {}

extension ConditionEvaluable {
    func getValue() -> Int? {
        switch self {
        case let .metaLevel(loadable: loadable, evaluatingKeyPath: evaluatingKeyPath):
            guard let metaLevel: MetaLevel = MetaLevelStorage().loadMetaLevel(name: loadable.name) else {
                return nil
            }
            return metaLevel.evaluate(given: evaluatingKeyPath)
        case let .level(loadable: loadable, evaluatingKeyPath: evaluatingKeyPath):
            guard let level = LevelStorage().loadLevel(name: loadable.name) else {
                return nil
            }
            return level.evaluate(given: evaluatingKeyPath)
        case .player:
            // TODO
            return -1
        case .numericLiteral(let literal):
            return literal
        }
    }
}

// MARK: Persistence
extension ConditionEvaluable {
    func toPersistable() -> PersistableConditionEvaluable {
        switch self {
        case let .metaLevel(loadable: loadable, evaluatingKeyPath: evaluatingKeyPath):
            return .metaLevel(
                loadable: loadable,
                evaluatingKeyPath: evaluatingKeyPath.toPersistable()
            )
        case let .level(loadable: loadable, evaluatingKeyPath: evaluatingKeyPath):
            return .level(
                loadable: loadable,
                evaluatingKeyPath: evaluatingKeyPath.toPersistable()
            )
        case .player:
            return .player
        case .numericLiteral(let literal):
            return .numericLiteral(literal)
        }
    }

    static func fromPersistable(_ persistableConditionEvaluable: PersistableConditionEvaluable) -> ConditionEvaluable {
        switch persistableConditionEvaluable {
        case let .metaLevel(loadable, evaluatingKeyPath):
            guard let namedKeyPath = MetaLevel.keyPathfromPersistable(evaluatingKeyPath) else {
                fatalError("missing key path")
            }
            return .metaLevel(
                loadable: loadable,
                evaluatingKeyPath: namedKeyPath
            )
        case let .level(loadable, evaluatingKeyPath):
            guard let namedKeyPath = Level.keyPathfromPersistable(evaluatingKeyPath) else {
                fatalError("missing key path")
            }
            return .level(
                loadable: loadable,
                evaluatingKeyPath: namedKeyPath
            )
        case .player:
            return .player
        case .numericLiteral(let literal):
            return .numericLiteral(literal)
        }
    }
}

enum PersistableConditionEvaluable: Codable {
    case metaLevel(loadable: Loadable, evaluatingKeyPath: PersistableNamedKeyPath)
    case level(loadable: Loadable, evaluatingKeyPath: PersistableNamedKeyPath)
    case player
    case numericLiteral(Int)
}

enum ConditionRelation {
    case eq
    case geq
    case leq
    case lt
    case gt
}

extension ConditionRelation: Codable {}

extension ConditionRelation: Hashable {}

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

// extension Condition: Hashable {
//    static func == (lhs: Condition, rhs: Condition) -> Bool {
//        lhs === rhs
//    }
// }

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

struct PersistableCondition {
    var subject: PersistableConditionEvaluable
    var relation: ConditionRelation
    var object: PersistableConditionEvaluable
}

extension PersistableCondition: Codable {}
