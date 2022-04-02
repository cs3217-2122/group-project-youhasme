//
//  HasVerbConcatNounState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class HasVerbConcatNounState: DFAState {
    weak var delegate: DFATransitionDelegate?
    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        
        switch entityType {
        case .connective(let connective) where connective == .and:
            delegate.stateTransition(to: HasVerbPrimedState())
        default:
            delegate.stateTransition(to: RejectingState())
        }
    }
}
