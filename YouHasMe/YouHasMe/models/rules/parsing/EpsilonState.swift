//
//  EpsilonState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
final class EpsilonState: DFAState {
    weak var dungeonDelegate: ConditionEvaluableDungeonDelegate?
    weak var delegate: DFATransitionDelegate?
    var unconfirmedRulesData = RulesData()
    let isAccepting = false

    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        switch entityType {
        case .noun(let noun):
            unconfirmedRulesData.receivers.append(noun)
            delegate.stateTransition(to: NounState(unconfirmedRulesData: unconfirmedRulesData))
        default:
            delegate.stateTransition(to: RejectingState())
        }
    }
}
