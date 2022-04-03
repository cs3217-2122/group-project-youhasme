//
//  MinimumLengthMatchingStrategy.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
class QuadDirectionalMatchingStrategy: SentenceMatchingStrategy {
    func match(block: EntityBlock, startingFrom index: (i: Int, j: Int)) -> [Sentence] {
        let (i, j) = index

        var northwardCandidateSentence: Sentence = []
        for k in stride(from: i, through: 0, by: -1) {
            guard let entityTypes = block[k][j],
                  let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                break
            }

            northwardCandidateSentence.append(metaData)
        }

        var southwardCandidateSentence: Sentence = []
        for k in i..<block.count {
            guard let entityTypes = block[k][j],
                  let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                break
            }

            southwardCandidateSentence.append(metaData)
        }

        var westwardCandidateSentence: Sentence = []
        for k in stride(from: j, to: 0, by: -1) {
            guard let entityTypes = block[i][k],
                  let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                break
            }

            westwardCandidateSentence.append(metaData)
        }

        var eastwardCandidateSentence: Sentence = []
        for k in j..<block[0].count {
            guard let entityTypes = block[i][k],
                  let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                break
            }
            eastwardCandidateSentence.append(metaData)
        }

        return [
            westwardCandidateSentence,
            eastwardCandidateSentence,
            northwardCandidateSentence,
            southwardCandidateSentence
        ]
    }
}
