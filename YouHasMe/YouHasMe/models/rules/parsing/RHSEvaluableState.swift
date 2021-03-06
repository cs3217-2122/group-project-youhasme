//
//  RHSEvaluableState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
final class RHSEvaluableState: DFAState {
    weak var dungeonDelegate: ConditionEvaluableDungeonDelegate?
    weak var delegate: DFATransitionDelegate?
    var unconfirmedRulesData: RulesData
    let isAccepting = true

    init(unconfirmedRulesData: RulesData) {
        self.unconfirmedRulesData = unconfirmedRulesData
    }

    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard case .connective(let connective) = entityType, connective == .and else {
            delegate.stateTransition(to: RejectingState())
            return
        }

        delegate.stateTransition(to: IfState(unconfirmedRulesData: unconfirmedRulesData))
    }
}
