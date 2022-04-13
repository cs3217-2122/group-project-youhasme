//
//  RejectingState.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class RejectingState: DFAState {
    weak var dungeonDelegate: ConditionEvaluableDungeonDelegate?
    weak var delegate: DFATransitionDelegate?
    var unconfirmedRulesData = RulesData()
    let isAccepting = false

    // Rejection state can only lead to itself.
    func read(entityType: Classification) {}
}
