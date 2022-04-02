//
//  MaximumLengthMatchingStrategy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class SouthwardEastwardMatchingStrategy: SentenceMatchingStrategy {
    func match(block: EntityBlock, startingFrom index: (i: Int, j: Int)) -> [Sentence] {
        let (i, j) = index
        var southwardCandidateSentence: Sentence = []
        for k in i..<block.count {
            guard let entityTypes = block[k][j],
                  let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                break
            }

            southwardCandidateSentence.append(metaData)
        }
        var eastwardCandidateSentence: Sentence = []
        for k in j..<block[0].count {
            guard let entityTypes = block[i][k],
                  let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                break
            }
            eastwardCandidateSentence.append(metaData)
        }
        return [southwardCandidateSentence, eastwardCandidateSentence]
    }
}
