//
//  ConditionalRuleValidationStrategy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation

protocol RuleResolutionPolicy {
    func resolve(given candidateActiveRules: [Rule]) -> [Rule]
}

class ConditionalRuleValidationStrategy: RuleValidationStrategy {
    private let ruleResolutionPolicies: [RuleResolutionPolicy] = [
        IsVerbDisjointSetPolicy()
    ]

    func validate(rules: [Rule]) -> [Rule] {
        var activeRules: [Rule] = []
        for rule in rules {
            if rule.conditions.allSatisfy({ $0.isConditionMet() }) {
                activeRules.append(rule)
            }
        }

        for ruleResolutionPolicy in ruleResolutionPolicies {
            activeRules = ruleResolutionPolicy.resolve(given: activeRules)
        }

        return activeRules
    }
}
