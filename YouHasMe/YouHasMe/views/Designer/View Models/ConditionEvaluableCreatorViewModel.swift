//
//  ConditionEvaluableCreatorViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 5/4/22.
//

import Foundation
protocol ConditionEvaluableCreatorViewModelDelegate: AnyObject {
    func getLevelNameToPositionMap() -> [String: Point]
    func addConditionEvaluable(conditionEvaluable: ConditionEvaluable)
    func getConditionEvaluableDelegate() -> ConditionEvaluableDungeonDelegate
    func finishCreation()
}

enum ConditionEvaluableBuildError: String, Error {
    case emptyConditionType = "Empty Condition Type"
    case buildError = "Failed to build condition"
}

class ConditionEvaluableCreatorViewModel: ObservableObject {
    weak var delegate: ConditionEvaluableCreatorViewModelDelegate?
    @Published var buildResultMessage: String?
    @Published var selectedConditionTypeId: String?
    @Published var selectedFieldId: String?
    @Published var selectedIdentifier: Point?
    @Published var selectedNumericLiteralIndex: Int = 0
    @Published var numericLiteral: String = "0"
    let numericLiteralRange = 0..<20

    var levelMetadata: [LevelMetadata] {
        guard let delegate = delegate else {
            return []
        }

        return LevelMetadata.levelNameToPositionMapToMetadata(delegate.getLevelNameToPositionMap())
    }

    private var selectedNumericLiteral: Int {
        numericLiteralRange.index(
            numericLiteralRange.startIndex, offsetBy: selectedNumericLiteralIndex
        )
    }

    private func createConditionEvaluable(
        conditionTypeId: String,
        literal: Int? = nil,
        fieldId: String? = nil,
        identifier: Point? = nil
    ) -> ConditionEvaluableType? {
        guard let type = ConditionType.getEnum(by: conditionTypeId) else {
            fatalError("condition type not found")
        }
        switch type {
        case .dungeon:
            guard let fieldId = fieldId else {
                return nil
            }
            let namedKeyPath = Dungeon.getNamedKeyPath(given: fieldId)
            return .dungeon(evaluatingKeyPath: namedKeyPath)
        case .level:
            guard let identifier = identifier,
                  let fieldId = fieldId else {
                      return nil
            }
            let namedKeyPath = Level.getNamedKeyPath(given: fieldId)
            return .level(id: identifier, evaluatingKeyPath: namedKeyPath)
        case .player:
            return .player
        case .numericLiteral:
            guard let literal = literal else {
                return nil
            }

            return .numericLiteral(literal)
        }
    }

    func confirm() -> Result<ConditionEvaluable, ConditionEvaluableBuildError> {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard let selectedConditionTypeId = selectedConditionTypeId else {
            return .failure(.emptyConditionType)
        }

        guard let type = createConditionEvaluable(
            conditionTypeId: selectedConditionTypeId,
            literal: selectedNumericLiteral,
            fieldId: selectedFieldId,
            identifier: selectedIdentifier
        ) else {
            return .failure(.buildError)
        }

        var conditionEvaluable = ConditionEvaluable(evaluableType: type)
        delegate.addConditionEvaluable(conditionEvaluable: conditionEvaluable)
        conditionEvaluable.delegate = delegate.getConditionEvaluableDelegate()
        return .success(conditionEvaluable)
    }

    func finish() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        delegate.finishCreation()
    }
}
