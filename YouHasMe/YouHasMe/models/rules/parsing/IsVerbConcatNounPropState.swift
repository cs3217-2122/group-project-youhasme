//
//  IsVerbConcatNounPropState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
final class IsVerbConcatNounPropState: DFAState {
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

        guard case .connective(let connective) = entityType else {
            delegate.stateTransition(to: RejectingState())
            return
        }

        switch connective {
        case .and:
            delegate.stateTransition(to: IsVerbPrimedState(unconfirmedRulesData: unconfirmedRulesData))
        case .cIf:
            delegate.stateTransition(to: IfState(unconfirmedRulesData: unconfirmedRulesData))
        }
    }
}
