//
//  WrapAroundMatchingStrategy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
class WrapAroundMatchingStrategy: SentenceMatchingStrategy {
    func match(block: EntityBlock, startingFrom index: (i: Int, j: Int)) -> [Sentence] {
        let (i, j) = index
        var southwardCandidateSentence: Sentence = []
        var k = i
        repeat {
            guard let entityTypes = block[k][j],
                  let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                break
            }

            southwardCandidateSentence.append(metaData)
            k += 1
            if k == block.count {
                k = 0
            }
        } while k != i

        var eastwardCandidateSentence: Sentence = []
        k = j
        repeat {
            guard let entityTypes = block[i][k],
                  let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                break
            }
            eastwardCandidateSentence.append(metaData)
            k += 1
            if k == block[0].count {
                k = 0
            }
        } while k != j
        return [southwardCandidateSentence, eastwardCandidateSentence]
    }
}
