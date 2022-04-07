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

    weak var conditionEvaluableDelegate: ConditionEvaluableDungeonDelegate?
    var subject: ConditionEvaluable?
    var relation: ConditionRelation?
    var object: ConditionEvaluable?

    func buildConditionEvaluableDelegate(_ delegate: ConditionEvaluableDungeonDelegate?) {
        conditionEvaluableDelegate = delegate
    }

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
            guard let fieldId = fieldId else {
                      throw BuildError.componentError
            }
            let namedKeyPath = Dungeon.getNamedKeyPath(given: fieldId)
            return .dungeon(evaluatingKeyPath: namedKeyPath)
        case .level:
            guard let identifier = identifier,
                  let fieldId = fieldId else {
                      throw BuildError.componentError
            }
            let namedKeyPath = Level.getNamedKeyPath(given: fieldId)
            return .level(id: identifier, evaluatingKeyPath: namedKeyPath)
        case .player:
            return .player
        case .numericLiteral:
            guard let literal = literal else {
                throw BuildError.componentError
            }

            return .numericLiteral(literal)
        }
    }

    func buildSubject(
        conditionSubjectTypeId: String,
        subjectLiteral: Int? = nil,
        subjectFieldId: String? = nil,
        subjectIdentifier: Point? = nil
    ) throws {
        let subjectType = try createConditionEvaluable(
            conditionTypeId: conditionSubjectTypeId,
            literal: subjectLiteral,
            fieldId: subjectFieldId,
            identifier: subjectIdentifier
        )
        buildSubject(subjectType: subjectType)
    }

    func buildSubject(subjectType: ConditionEvaluableType) {
        buildSubject(ConditionEvaluable(evaluableType: subjectType))
    }

    func buildSubject(_ subject: ConditionEvaluable) {
        self.subject = subject
    }

    func buildRelation(
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

    func buildRelation(_ relation: ConditionRelation) {
        self.relation = relation
    }

    func buildObject(
        conditionObjectTypeId: String,
        objectLiteral: Int? = nil,
        objectFieldId: String? = nil,
        objectIdentifier: Point? = nil
    ) throws {
        let objectType = try createConditionEvaluable(
            conditionTypeId: conditionObjectTypeId,
            literal: objectLiteral,
            fieldId: objectFieldId,
            identifier: objectIdentifier
        )
        buildObject(objectType: objectType)
    }

    func buildObject(objectType: ConditionEvaluableType) {
        buildObject(ConditionEvaluable(evaluableType: objectType))
    }

    func buildObject(_ object: ConditionEvaluable) {
        self.object = object
    }

    func getResult() throws -> Condition {
        guard var subject = subject else {
            throw BuildError.subjectNil
        }
        subject.delegate = conditionEvaluableDelegate

        guard let relation = relation else {
            throw BuildError.relationNil
        }

        guard var object = object else {
            throw BuildError.objectNil
        }
        object.delegate = conditionEvaluableDelegate

        return Condition(
            subject: subject,
            relation: relation,
            object: object
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
