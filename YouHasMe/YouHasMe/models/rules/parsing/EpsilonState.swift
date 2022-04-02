//
//  EpsilonState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class EpsilonState: DFAState {
    weak var delegate: DFATransitionDelegate?
    
    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        switch entityType {
        case .noun(let noun):
            delegate.rulesData.receivers.append(noun)
            delegate.stateTransition(to: NounState())
        default:
            delegate.stateTransition(to: RejectingState())
        }
    }
}
