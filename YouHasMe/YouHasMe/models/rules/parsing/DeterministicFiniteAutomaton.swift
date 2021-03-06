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
    var conditionBuilders: [ConditionBuilder] = []

    func combine(with otherRulesData: RulesData) {
        self.receivers.append(contentsOf: otherRulesData.receivers)
        self.properties.append(contentsOf: otherRulesData.properties)
        self.isObjects.append(contentsOf: otherRulesData.isObjects)
        self.hasObjects.append(contentsOf: otherRulesData.hasObjects)
        self.conditionBuilders.append(contentsOf: otherRulesData.conditionBuilders)
        otherRulesData.receivers.removeAll()
        otherRulesData.properties.removeAll()
        otherRulesData.isObjects.removeAll()
        otherRulesData.hasObjects.removeAll()
        otherRulesData.conditionBuilders.removeAll()
    }
}

extension RulesData: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        \(receivers)
        \(properties)
        \(isObjects)
        \(hasObjects)

        """
    }
}

protocol DFATransitionDelegate: AnyObject {
    var rulesData: RulesData { get }
    var stateHistory: [DFAState] { get }
    func stateTransition<State: DFAState>(to newState: State)
}

protocol DFAState: AnyObject {
    var dungeonDelegate: ConditionEvaluableDungeonDelegate? { get set }
    var delegate: DFATransitionDelegate? { get set }
    var unconfirmedRulesData: RulesData { get set }
    var isAccepting: Bool { get }
    func read(entityType: Classification)
    func buildRules() -> [Rule]
}

extension DFAState {
    var isRejecting: Bool {
        !isAccepting
    }

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

        var conditions: [Condition] = []
        for builder in rulesData.conditionBuilders {
            do {
                builder.buildConditionEvaluableDelegate(dungeonDelegate)
                let condition = try builder.getResult()
                conditions.append(condition)
            } catch {
                fatalError("unexpected build error")
            }
        }

        for i in 0..<rules.count {
            rules[i].conditions.append(contentsOf: conditions)
        }

        return rules
    }
}

protocol DeterministicFiniteAutomaton: SentenceParsingStrategy, DFATransitionDelegate {
    var dungeonDelegate: ConditionEvaluableDungeonDelegate? { get }
    var rulesData: RulesData { get set }
    var stateHistory: [DFAState] { get set }
}

extension DeterministicFiniteAutomaton {
    var state: DFAState {
        get {
            guard let mostRecentState = stateHistory.last else {
                fatalError("states should not be empty")
            }
            return mostRecentState
        }
        set {
            newValue.dungeonDelegate = dungeonDelegate
            stateHistory.append(newValue)
        }
    }

    func reset() {
        stateHistory = [EpsilonState()]
        state.delegate = self
        rulesData = RulesData()
    }

    func read(entityType: Classification) {
        state.read(entityType: entityType)
    }

    func buildRules() -> [Rule] {
        state.buildRules()
    }

    func stateTransition<State>(to newState: State) where State: DFAState {
        newState.delegate = self
        self.state = newState
        if state.isAccepting {
            rulesData.combine(with: state.unconfirmedRulesData)
        }
    }
}
