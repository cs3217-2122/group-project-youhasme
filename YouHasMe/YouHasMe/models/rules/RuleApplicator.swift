//
//  RuleApplicator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 10/4/22.
//

import Foundation
class RuleApplicator {
    func applyRules(_ rules: [Rule], to entity: inout Entity) {
        var behaviours: Set<Behaviour> = []
        switch entity.entityType.classification {
        case .noun, .verb, .connective, .property:
            for rule in rules {
                guard rule.receiver == .word else {
                    continue
                }
                behaviours.insert(rule.activateToBehaviour())
            }
        case .nounInstance(let noun):
            for rule in rules {
                guard rule.receiver == noun else {
                    continue
                }

                behaviours.insert(rule.activateToBehaviour())
            }
        default:
            break
        }

        entity.activeBehaviours = behaviours
    }
}
