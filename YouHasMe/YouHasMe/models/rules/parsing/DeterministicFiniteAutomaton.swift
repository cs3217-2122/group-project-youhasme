//
//  DeterministicFiniteAutomaton.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation

class RulesData {
    var receivers: [Noun] = []
    var properties: [Property] = []
    var isObjects: [Noun] = []
    var hasObjects: [Noun] = []
}

protocol DFATransitionDelegate: AnyObject {
    var rulesData: RulesData { get }
    func stateTransition<State: DFAState>(to newState: State)
}

// tokenizer
protocol DFAState: AnyObject {
    var delegate: DFATransitionDelegate? { get set }
    func read(entityType: Classification)
    func buildRules() -> [Rule]
}

extension DFAState {
    func buildRules() -> [Rule] {
        func buildRules() -> [Rule] {
            guard let delegate = delegate else {
                return []
            }
            let rulesData = delegate.rulesData
            var rules: [Rule] = []
            for noun in rulesData.receivers {
                for property in rulesData.properties {
                    rules.append(Rule(receiver: noun, verb: .vIs, performer: .property(property)))
                }
                for otherNoun in rulesData.isObjects {
                    rules.append(Rule(receiver: noun, verb: .vIs, performer: .noun(otherNoun)))
                }
                for otherNoun in rulesData.hasObjects {
                    rules.append(Rule(receiver: noun, verb: .vHas, performer: .noun(otherNoun)))
                }
            }
            return rules
        }
    }
}

class DeterministicFiniteAutomaton: SentenceParsingStrategy {
    var rulesData: RulesData

    var state: DFAState = EpsilonState()
    
    init() {
        state.delegate = self
    }
    
    func read(entityType: Classification) {
        state.read(entityType: entityType)
    }
    
    func buildRules() -> [Rule] {
        state.buildRules()
    }
    
    func parse(sentence: Sentence) -> [Rule] {
        for word in sentence {
            read(entityType: word)
        }
        
        return buildRules()
    }
}

extension DeterministicFiniteAutomaton: DFATransitionDelegate {
    func stateTransition<State>(to newState: State) where State : DFAState {
        newState.delegate = self
        self.state = newState
    }
}
