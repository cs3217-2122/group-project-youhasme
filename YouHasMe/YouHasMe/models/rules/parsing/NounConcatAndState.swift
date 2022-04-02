//
//  NounConcatAndState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class NounConcatAndState: DFAState {
    weak var delegate: DFATransitionDelegate?
    
    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard case .noun(let noun) = entityType else {
            delegate.stateTransition(to: RejectingState())
            return
        }
        
        delegate.rulesData.receivers.append(noun)
        delegate.stateTransition(to: NounState())
    }
}
