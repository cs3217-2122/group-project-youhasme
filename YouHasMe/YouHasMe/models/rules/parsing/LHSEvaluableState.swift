//
//  LHSEvaluableState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
final class LHSEvaluableState: DFAState {
    weak var delegate: DFATransitionDelegate?
    var unconfirmedRulesData: RulesData
    let isAccepting = false

    init(unconfirmedRulesData: RulesData) {
        self.unconfirmedRulesData = unconfirmedRulesData
    }

    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard case .conditionRelation(let conditionRelation) = entityType else {
            delegate.stateTransition(to: RejectingState())
            return
        }

        guard let builder = unconfirmedRulesData.conditionBuilders.last else {
            fatalError("should not be nil")
        }
        builder.buildRelation(conditionRelation)
        delegate.stateTransition(to: ConditionRelationState(unconfirmedRulesData: unconfirmedRulesData))
    }
}
