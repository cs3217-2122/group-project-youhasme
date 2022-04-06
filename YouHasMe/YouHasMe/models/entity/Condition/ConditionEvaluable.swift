//
//  ConditionEvaluable.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
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
        case let .level(id, evaluatingKeyPath):
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

    static func fromPersistable(
        _ persistableConditionEvaluable: PersistableConditionEvaluableType
    ) -> ConditionEvaluableType {
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
