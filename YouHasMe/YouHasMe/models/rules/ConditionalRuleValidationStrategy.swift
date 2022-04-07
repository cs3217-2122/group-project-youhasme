//
//  ConditionalRuleValidationStrategy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
class ConditionalRuleValidationStrategy: RuleValidationStrategy {
    func validate(rules: [Rule], for entity: inout Entity, environment: LevelLayer) {
        var behaviours: Set<Behaviour> = []
        switch entity.entityType.classification {
        case .noun, .verb, .connective, .property:
            for rule in rules {
                guard rule.receiver == .word else {
                    continue
                }

                if rule.conditions.allSatisfy({ $0.isConditionMet() }) {
                    behaviours.insert(rule.activateToBehaviour())
                }
            }
        case .nounInstance(let noun):
            for rule in rules {
                guard rule.receiver == noun else {
                    continue
                }
                if rule.conditions.allSatisfy({ $0.isConditionMet() }) {
                    behaviours.insert(rule.activateToBehaviour())
                }
            }
        default:
            break
        }

        entity.activeBehaviours = behaviours
    }
}
