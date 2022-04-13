//
//  IsVerbState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
final class IsVerbState: DFAState {
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
            unconfirmedRulesData.isObjects.append(noun)
            delegate.stateTransition(to: IsVerbConcatNounPropState(unconfirmedRulesData: unconfirmedRulesData))
            return
        case .property(let property):
            unconfirmedRulesData.properties.append(property)
            delegate.stateTransition(to: IsVerbConcatNounPropState(unconfirmedRulesData: unconfirmedRulesData))
            return
        default:
            break
        }
    }
}
