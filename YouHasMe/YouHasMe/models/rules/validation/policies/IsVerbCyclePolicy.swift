//
//  IsVerbCyclePolicy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 10/4/22.
//

import Foundation

extension AdjacencyListGraph {
    func addDirectedEdge(_ from: T, to: T) {
        addDirectedEdge(createVertex(from), to: createVertex(to), withWeight: nil)
    }

    func hasPath(from source: T, to dest: T) -> Bool {
        var visitedData: Set<T> = [source]
        var frontier = Queue<T>()
        frontier.enqueue(source)
        // breadth first search
        while let toExplore = frontier.dequeue() {
            let vertex = createVertex(toExplore)
            for edge in edgesFrom(vertex) {
                let data = edge.to.data
                guard !visitedData.contains(data) else {
                    continue
                }
                visitedData.insert(data)
                frontier.enqueue(data)
            }

            if visitedData.contains(dest) {
                break
            }
        }

        return visitedData.contains(dest)
    }
}

class IsVerbCyclePolicy: RuleResolutionPolicy {
    func resolve(given candidateActiveRules: [Rule]) -> [Rule] {
        var activeRules: [Rule] = []
        let graph = AdjacencyListGraph<Noun>()

        for activeRule in candidateActiveRules {
            guard activeRule.verb == .vIs else {
                continue
            }

            let receiver = activeRule.receiver

            switch activeRule.performer {
            case .noun(let target):
                guard !graph.hasPath(from: target, to: receiver) else {
                    continue
                }

                graph.addDirectedEdge(receiver, to: target)

                activeRules.append(activeRule)
            default:
                activeRules.append(activeRule)
            }
        }

        return activeRules
    }
}
