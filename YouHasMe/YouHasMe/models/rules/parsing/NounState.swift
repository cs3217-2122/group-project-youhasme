//
//  NounState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
final class NounState: DFAState {
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
        case .verb(let verb):
            switch verb {
            case .vIs:
                delegate.stateTransition(to: IsVerbState(unconfirmedRulesData: unconfirmedRulesData))
            case .vHas:
                delegate.stateTransition(to: HasVerbState(unconfirmedRulesData: unconfirmedRulesData))
            }
        case .connective(let connectiveType) where connectiveType == .and:
            delegate.stateTransition(to: NounConcatAndState(unconfirmedRulesData: unconfirmedRulesData))
        default:
            delegate.stateTransition(to: RejectingState())
        }
    }
}
