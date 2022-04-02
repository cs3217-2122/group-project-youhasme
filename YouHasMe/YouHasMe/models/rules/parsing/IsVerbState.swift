//
//  IsVerbState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class IsVerbState: DFAState {
    weak var delegate: DFATransitionDelegate?
    func read(entityType: Classification) {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        
        switch entityType {
        case .noun(let noun):
            delegate.rulesData.isObjects.append(noun)
            delegate.stateTransition(to: IsVerbConcatNounPropState())
            return
        case .property(let property):
            delegate.rulesData.properties.append(property)
            delegate.stateTransition(to: IsVerbConcatNounPropState())
            return
        default:
            break
        }
    }
}
