//
//  IsVerbDisjointSetPolicy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 10/4/22.
//

import Foundation

class IsVerbDisjointSetPolicy: RuleResolutionPolicy {
    func resolve(given candidateActiveRules: [Rule]) -> [Rule] {
        var activeRules: [Rule] = []
        var disjointSet = UnionFind<Noun>()
        Noun.allCases.forEach {
            disjointSet.addSetWith($0)
        }

        for activeRule in candidateActiveRules {
            guard activeRule.verb == .vIs else {
                activeRules.append(activeRule)
                continue
            }

            let receiver = activeRule.receiver

            switch activeRule.performer {
            case .noun(let target):
                guard disjointSet.isElementRepresentativeOfSet(receiver) else {
                    continue
                }

                guard !disjointSet.inSameSet(receiver, and: target) else {
                    continue
                }

                disjointSet.unionSetsContaining(representative: target, other: receiver)

                activeRules.append(activeRule)
            default:
                activeRules.append(activeRule)
            }
        }

        return activeRules
    }
}
