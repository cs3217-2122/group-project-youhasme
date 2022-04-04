import Foundation

typealias Sentence = [Classification]

protocol SentenceMatchingStrategy {
    func match(block: EntityBlock, startingFrom index: (i: Int, j: Int)) -> [Sentence]
}

protocol SentenceParsingStrategy {
    func parse(sentence: Sentence) -> [Rule]
}

class RuleParser {
    var sentenceMatchingStrategy: SentenceMatchingStrategy
    var sentenceParsingStrategy: SentenceParsingStrategy
    init(
        sentenceMatchingStrategy: SentenceMatchingStrategy,
        sentenceParsingStrategy: SentenceParsingStrategy
    ) {
        self.sentenceMatchingStrategy = sentenceMatchingStrategy
        self.sentenceParsingStrategy = sentenceParsingStrategy
    }

    func parse(block: EntityBlock) -> [Rule] {
        var rules: [Rule] = DefaultRules.rules
        var sentences: [Sentence] = []
        for i in 0..<block.count {
            for j in 0..<block[0].count {
                sentences.append(
                    contentsOf: sentenceMatchingStrategy.match(block: block, startingFrom: (i, j))
                )
            }
        }

        for sentence in sentences {
            rules.append(contentsOf: sentenceParsingStrategy.parse(sentence: sentence))
        }
        return rules
    }
}
