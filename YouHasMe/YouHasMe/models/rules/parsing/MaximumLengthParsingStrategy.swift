//
//  MaximumLengthParsingStrategy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
class MaximumLengthParsingStrategy: DeterministicFiniteAutomaton {
    var rulesData = RulesData()

    var stateHistory: [DFAState] = []

    func parse(sentence: Sentence) -> [Rule] {
        reset()

        for word in sentence {
            read(entityType: word)
        }

        return buildRules()
    }
}
