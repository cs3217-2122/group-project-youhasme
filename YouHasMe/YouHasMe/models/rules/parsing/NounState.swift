//
//  NounState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class NounState: DFAState {
    weak var delegate: DFATransitionDelegate?
    
    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        
        switch entityType {
        case .verb(let verb):
            switch verb {
            case .vIs:
                delegate.stateTransition(to: IsVerbState())
            case .vHas:
                delegate.stateTransition(to: HasVerbState())
            }
        case .connective(let connectiveType) where connectiveType == .and:
            delegate.stateTransition(to: NounConcatAndState())
        default:
            delegate.stateTransition(to: RejectingState())
        }
    }
}
