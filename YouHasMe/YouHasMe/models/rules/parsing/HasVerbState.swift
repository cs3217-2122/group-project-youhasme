//
//  HasVerbState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
final class HasVerbState: DFAState {
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

        switch entityType {
        case .noun(let noun):
            unconfirmedRulesData.hasObjects.append(noun)
            delegate.stateTransition(to: HasVerbConcatNounState(unconfirmedRulesData: unconfirmedRulesData))
        default:
            delegate.stateTransition(to: RejectingState())
        }
    }
}
