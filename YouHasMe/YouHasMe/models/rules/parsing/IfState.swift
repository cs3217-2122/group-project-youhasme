//
//  IfState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
final class IfState: DFAState {
    weak var dungeonDelegate: ConditionEvaluableDungeonDelegate?
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

        guard case .conditionEvaluable(let conditionEvaluable) = entityType else {
            delegate.stateTransition(to: RejectingState())
            return
        }

        let builder = ConditionBuilder()
        builder.buildSubject(conditionEvaluable)
        unconfirmedRulesData.conditionBuilders.append(builder)
        delegate.stateTransition(to: LHSEvaluableState(unconfirmedRulesData: unconfirmedRulesData))
    }
}
