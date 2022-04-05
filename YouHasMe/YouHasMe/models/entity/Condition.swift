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

protocol ConditionEvaluableDungeonDelegate: AnyObject {
    var dungeon: Dungeon { get }
    var dungeonName: String { get }
    func getLevel(by id: Point) -> Level
    func getLevelName(by id: Point) -> String
}

struct ConditionEvaluable {
    weak var delegate: ConditionEvaluableDungeonDelegate?
    var evaluableType: ConditionEvaluableType
}

extension ConditionEvaluable: Hashable {
    static func == (lhs: ConditionEvaluable, rhs: ConditionEvaluable) -> Bool {
        lhs.evaluableType == rhs.evaluableType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(evaluableType)
    }
}

extension ConditionEvaluable {
    func toPersistable() -> PersistableConditionEvaluable {
        PersistableConditionEvaluable(evaluableType: evaluableType.toPersistable())
    }

    static func fromPersistable(_ persistableConditionEvaluable: PersistableConditionEvaluable) -> ConditionEvaluable {
        ConditionEvaluable(evaluableType: ConditionEvaluableType.fromPersistable( persistableConditionEvaluable.evaluableType))
    }
}

struct PersistableConditionEvaluable {
    var evaluableType: PersistableConditionEvaluableType
}
extension PersistableConditionEvaluable: Codable {}

enum ConditionEvaluableType {
    case dungeon(evaluatingKeyPath: NamedKeyPath<Dungeon, Int>)
    case level(id: Point, evaluatingKeyPath: NamedKeyPath<Level, Int>)
    case player
    case numericLiteral(Int)
}

extension ConditionEvaluableType: Hashable {}

extension ConditionEvaluable: CustomStringConvertible {
    var description: String {
        switch evaluableType {
        case .dungeon(let evaluatingKeyPath):
            return "Dungeon: \(delegate?.dungeonName ?? "") \(evaluatingKeyPath.description)"
        case .level(let id, let evaluatingKeyPath):
            return "Level: \(delegate?.getLevelName(by: id) ?? "") -> \(evaluatingKeyPath.description)"
        case .player:
            return "Player"
        case .numericLiteral(let int):
            return "Value: \(int)"
        }
    }
}

extension ConditionEvaluable {
    func getValue() -> Int? {
        switch evaluableType {
        case let .dungeon(evaluatingKeyPath):
            guard let dungeon: Dungeon = delegate?.dungeon else {
                return nil
            }
            return dungeon.evaluate(given: evaluatingKeyPath)
        case let .level(id: id, evaluatingKeyPath: evaluatingKeyPath):
            guard let level = delegate?.getLevel(by: id) else {
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
extension ConditionEvaluableType {
    func toPersistable() -> PersistableConditionEvaluableType {
        switch self {
        case let .dungeon(evaluatingKeyPath: evaluatingKeyPath):
            return .dungeon(evaluatingKeyPath: evaluatingKeyPath.toPersistable())
        case let .level(id: id, evaluatingKeyPath: evaluatingKeyPath):
            return .level(
                id: id,
                evaluatingKeyPath: evaluatingKeyPath.toPersistable()
            )
        case .player:
            return .player
        case .numericLiteral(let literal):
            return .numericLiteral(literal)
        }
    }

    static func fromPersistable(_ persistableConditionEvaluable: PersistableConditionEvaluableType) -> ConditionEvaluableType {
        switch persistableConditionEvaluable {
        case let .dungeon(evaluatingKeyPath):
            guard let namedKeyPath = Dungeon.keyPathfromPersistable(evaluatingKeyPath) else {
                fatalError("missing key path")
            }
            return .dungeon(evaluatingKeyPath: namedKeyPath)
        case let .level(id, evaluatingKeyPath):
            guard let namedKeyPath = Level.keyPathfromPersistable(evaluatingKeyPath) else {
                fatalError("missing key path")
            }
            return .level(
                id: id,
                evaluatingKeyPath: namedKeyPath
            )
        case .player:
            return .player
        case .numericLiteral(let literal):
            return .numericLiteral(literal)
        }
    }
}

enum PersistableConditionEvaluableType: Codable {
    case dungeon(evaluatingKeyPath: PersistableNamedKeyPath)
    case level(id: Point, evaluatingKeyPath: PersistableNamedKeyPath)
    case player
    case numericLiteral(Int)
}

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

struct PersistableCondition {
    var subject: PersistableConditionEvaluable
    var relation: ConditionRelation
    var object: PersistableConditionEvaluable
}

extension PersistableCondition: Codable {}
