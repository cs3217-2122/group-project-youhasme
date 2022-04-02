//
//  HasVerbPrimedState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class HasVerbPrimedState: DFAState {
    weak var delegate: DFATransitionDelegate?
    
    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        switch entityType {
        case .noun(let noun):
            delegate.rulesData.hasObjects.append(noun)
            delegate.stateTransition(to: HasVerbConcatNounState())
        case .verb(let verb) where verb == .vIs:
            delegate.stateTransition(to: IsVerbState())
        default:
            delegate.stateTransition(to: RejectingState())
        }
    }
}
