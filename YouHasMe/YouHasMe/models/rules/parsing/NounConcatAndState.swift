//
//  NounConcatAndState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
final class NounConcatAndState: DFAState {
    weak var dungeonDelegate: ConditionEvaluableDungeonDelegate?
    weak var delegate: DFATransitionDelegate?
    let isAccepting = false
    var unconfirmedRulesData: RulesData

    init(unconfirmedRulesData: RulesData) {
        self.unconfirmedRulesData = unconfirmedRulesData
    }

    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard case .noun(let noun) = entityType else {
            delegate.stateTransition(to: RejectingState())
            return
        }

        unconfirmedRulesData.receivers.append(noun)
        delegate.stateTransition(to: NounState(unconfirmedRulesData: unconfirmedRulesData))
    }
}
