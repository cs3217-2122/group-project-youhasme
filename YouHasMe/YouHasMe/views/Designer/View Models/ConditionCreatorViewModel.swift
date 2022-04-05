//
//  ConditionCreatorViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 31/3/22.
//

import Foundation
import Combine
class ConditionBuilder {
    enum BuildError: Error {
        case componentError
        case subjectNil
        case relationNil
        case objectNil
    }

    var subject: ConditionEvaluableType?
    var relation: ConditionRelation?
    var object: ConditionEvaluableType?

    private func createConditionEvaluable(
        conditionTypeId: String,
        literal: Int? = nil,
        fieldId: String? = nil,
        identifier: Point? = nil
    ) throws -> ConditionEvaluableType {
        guard let type = ConditionType.getEnum(by: conditionTypeId) else {
            fatalError("condition type not found")
        }
        switch type {
        case .dungeon:
            guard let fieldId = fieldId,
                  let namedKeyPath = Dungeon.getNamedKeyPath(given: fieldId)  else {
                      throw BuildError.componentError
            }
            return .dungeon(evaluatingKeyPath: namedKeyPath)
        case .level:
            guard let identifier = identifier,
                  let fieldId = fieldId,
                  let namedKeyPath = Level.getNamedKeyPath(given: fieldId) else {
                      throw BuildError.componentError
            }
            return .level(id: identifier, evaluatingKeyPath: namedKeyPath)
        case .player:
            return .player
        case .numericLiteral:
            return .numericLiteral(-1)
        }
    }

    func buildSubject(
        conditionSubjectTypeId: String,
        subjectLiteral: Int? = nil,
        subjectFieldId: String? = nil,
        subjectIdentifier: Point? = nil
    ) throws {
        subject = try createConditionEvaluable(
            conditionTypeId: conditionSubjectTypeId,
            literal: subjectLiteral,
            fieldId: subjectFieldId,
            identifier: subjectIdentifier
        )
    }

    func buildComparator(
        comparatorId: String
    ) throws {
        guard let comparator = ComparatorType.getEnum(by: comparatorId) else {
            fatalError("cannot find comparator")
        }

        switch comparator {
        case .eq:
            relation = .eq
        case .geq:
            relation = .geq
        case .leq:
            relation = .leq
        case .lt:
            relation = .lt
        case .gt:
            relation = .gt
        }
    }

    func buildObject(
        conditionObjectTypeId: String,
        objectLiteral: Int? = nil,
        objectFieldId: String? = nil,
        objectIdentifier: Point? = nil
    ) throws {
        object = try createConditionEvaluable(
            conditionTypeId: conditionObjectTypeId,
            literal: objectLiteral,
            fieldId: objectFieldId,
            identifier: objectIdentifier
        )
    }

    func getResult() throws -> Condition {
        guard let subject = subject else {
            throw BuildError.subjectNil
        }

        guard let relation = relation else {
            throw BuildError.relationNil
        }

        guard let object = object else {
            throw BuildError.objectNil
        }

        return Condition(
            subject: ConditionEvaluable(evaluableType: subject),
            relation: relation,
            object: ConditionEvaluable(evaluableType: object)
        )
    }
}

enum ConditionType: String {
    case dungeon = "Dungeon"
    case level = "Level"
    case player = "Player"
    case numericLiteral = "Numeric"

    func getKeyPaths() -> [AnyNamedKeyPath] {
        switch self {
        case .dungeon:
            return Dungeon.typeErasedNamedKeyPaths
        case .level:
            return Level.typeErasedNamedKeyPaths
        case .player:
            return []
        case .numericLiteral:
            return []
        }
    }

    func getStorageDependencies() -> [Loadable]? {
        switch self {
        case .dungeon:
            return nil
        case .level:
            return nil // TODO
        case .player:
            return nil
        case .numericLiteral:
            return nil
        }
    }
}

extension ConditionType: CaseIterable {}
extension ConditionType: Identifiable {
    var id: String {
        rawValue
    }

    static func getEnum(by id: String) -> ConditionType? {
        ConditionType.allCases.first { $0.id == id }
    }
}
extension ConditionType: CustomStringConvertible {
    var description: String {
        rawValue
    }
}

enum ComparatorType: String {
    case eq = "="
    case geq = ">="
    case leq = "<="
    case lt = "<"
    case gt = ">"
}
extension ComparatorType: CaseIterable {}
extension ComparatorType: Identifiable {
    var id: String {
        rawValue
    }

    static func getEnum(by id: String) -> ComparatorType? {
        ComparatorType.allCases.first { $0.id == id }
    }
}
extension ComparatorType: CustomStringConvertible {
    var description: String {
        rawValue
    }
}
