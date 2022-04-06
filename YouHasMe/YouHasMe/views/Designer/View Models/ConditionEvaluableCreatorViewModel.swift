//
//  ConditionEvaluableCreatorViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 5/4/22.
//

import Foundation
protocol ConditionEvaluableCreatorViewModelDelegate: AnyObject {
    func buildConditionEvaluable(conditionEvaluable: ConditionEvaluable)
}

class ConditionEvaluableCreatorViewModel: ObservableObject {
    weak var delegate: ConditionEvaluableCreatorViewModelDelegate?
    @Published var selectedConditionTypeId: String?
    @Published var selectedFieldId: String?
    @Published var selectedDependencyId: String?

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

    func confirm() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard let selectedConditionTypeId = selectedConditionTypeId else {
            return
        }

        guard let type = createConditionEvaluable(conditionTypeId: selectedConditionTypeId, literal: nil, fieldId: selectedFieldId, identifier: nil) else {
            return
        }

        let conditionEvaluable = ConditionEvaluable(evaluableType: type)
        delegate.buildConditionEvaluable(conditionEvaluable: conditionEvaluable)
    }
}
