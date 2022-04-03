//
//  MinimumLengthParsingStrategy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
class MinimumLengthParsingStrategy: DeterministicFiniteAutomaton {
    var rulesData = RulesData()

    var stateHistory: [DFAState] = []

    func parse(sentence: Sentence) -> [Rule] {
        reset()
        for word in sentence {
            read(entityType: word)
            if state.isAccepting {
                break
            }
        }

        return buildRules()
    }
}
