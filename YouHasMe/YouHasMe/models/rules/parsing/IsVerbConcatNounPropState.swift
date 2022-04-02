//
//  IsVerbConcatNounPropState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class IsVerbConcatNounPropState: DFAState {
    weak var delegate: DFATransitionDelegate?
    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard case .connective(let connective) = entityType, connective == .and else {
            delegate.stateTransition(to: RejectingState())
            return
        }
        
        delegate.stateTransition(to: IsVerbPrimedState())
    }
}
