//
//  RejectingState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class RejectingState: DFAState {
    weak var delegate: DFATransitionDelegate? = nil
    // Rejection state can only lead to itself.
    func read(entityType: Classification) {
        return
    }
}
