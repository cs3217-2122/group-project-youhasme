//
//  HasAtMostOnePolicy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 17/4/22.
//

import Foundation

class HasAtMostOnePolicy: RuleResolutionPolicy {
    func resolve(given candidateActiveRules: [Rule]) -> [Rule] {
        var activeRules: [Rule] = []
        var nounsAlreadyHavingSomething: Set<Noun> = []

        for activeRule in candidateActiveRules {
            guard activeRule.verb == .vHas else {
                activeRules.append(activeRule)
                continue
            }

            let receiver = activeRule.receiver
            guard !nounsAlreadyHavingSomething.contains(receiver) else {
                continue
            }

            nounsAlreadyHavingSomething.insert(receiver)
            activeRules.append(activeRule)
        }

        return activeRules
    }
}
