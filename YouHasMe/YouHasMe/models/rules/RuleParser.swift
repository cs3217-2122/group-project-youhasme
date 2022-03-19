import Foundation

class RuleParser {
    enum AutomataState {
        case epsilon
        case noun
        case noun_concat_and
        case isVerb
        case isVerbPrime
        case isVerb_concat_nounProp
        case hasVerb
        case hasVerbPrime
        case hasVerb_concat_noun
        case reject
    }
    class RuleParserState {
        var automataState: AutomataState = .epsilon
        var receivers: [Noun] = []
        var properties: [Property] = []
        var isObjects: [Noun] = []
        var hasObjects: [Noun] = []

        func getRules() -> [Rule] {
            var rules: [Rule] = []
            for noun in receivers {
                for property in properties {
                    rules.append(Rule(receiver: noun, verb: .vIs, performer: .property(property)))
                }
                for otherNoun in isObjects {
                    rules.append(Rule(receiver: noun, verb: .vIs, performer: .noun(otherNoun)))
                }
                for otherNoun in hasObjects {
                    rules.append(Rule(receiver: noun, verb: .vHas, performer: .noun(otherNoun)))
                }
            }
            return rules
        }
    }

    func transition(ruleParserState: RuleParserState, entityType: Classification) {
        switch ruleParserState.automataState {
        case .epsilon:
            switch entityType {
            case .noun(let noun):
                ruleParserState.receivers.append(noun)
                ruleParserState.automataState = .noun
                return
            default:
                break
            }
        case .noun:
            switch entityType {
            case .verb(let verb):
                switch verb {
                case .vIs:
                    ruleParserState.automataState = .isVerb
                case .vHas:
                    ruleParserState.automataState = .hasVerb
                }
                return
            case .connective(let connectiveType) where connectiveType == .and:
                ruleParserState.automataState = .noun_concat_and
                return
            default:
                break
            }

        case .noun_concat_and:
            if case .noun(let noun) = entityType {
                ruleParserState.receivers.append(noun)
                ruleParserState.automataState = .noun
                return
            }
        case .isVerb:
            switch entityType {
            case .noun(let noun):
                ruleParserState.isObjects.append(noun)
                ruleParserState.automataState = .isVerb_concat_nounProp
                return
            case .property(let property):
                ruleParserState.properties.append(property)
                ruleParserState.automataState = .isVerb_concat_nounProp
                return
            default:
                break
            }
        case .isVerbPrime:
            switch entityType {
            case .noun(let noun):
                ruleParserState.isObjects.append(noun)
                ruleParserState.automataState = .isVerb_concat_nounProp
                return
            case .property(let property):
                ruleParserState.properties.append(property)
                ruleParserState.automataState = .isVerb_concat_nounProp
                return
            case .verb(let verbType) where verbType == .vHas:
                ruleParserState.automataState = .hasVerb
                return
            default:
                break
            }
        case .isVerb_concat_nounProp:
            if case .connective(let connective) = entityType, connective == .and {
                ruleParserState.automataState = .isVerbPrime
                return
            }
        case .hasVerb:
            switch entityType {
            case .noun(let noun):
                ruleParserState.hasObjects.append(noun)
                ruleParserState.automataState = .hasVerb_concat_noun
                return
            default:
                break
            }
        case .hasVerbPrime:
            switch entityType {
            case .noun(let noun):
                ruleParserState.hasObjects.append(noun)
                ruleParserState.automataState = .hasVerb_concat_noun
                return
            case .verb(let verb) where verb == .vIs:
                ruleParserState.automataState = .isVerb
                return
            default:
                break
            }
        case .hasVerb_concat_noun:
            switch entityType {
            case .connective(let connective) where connective == .and:
                ruleParserState.automataState = .hasVerbPrime
                return
            default:
                break
            }
        case .reject:
            break
        }
        ruleParserState.automataState = .reject
    }

    func parse(sentence: [Classification]) -> [Rule] {
        let ruleParserState = RuleParserState()
        for entityType in sentence {
            transition(ruleParserState: ruleParserState, entityType: entityType)
        }
        return ruleParserState.getRules()
    }

    func parse(block: EntityBlock) -> [Rule] {
        var rules: [Rule] = []
        for i in 0..<block.count {
            for j in 0..<block[0].count {

                var verticalCandidateSentence: [Classification] = []
                for k in i..<block.count {
                    guard let entityTypes = block[k][j],
                          let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                        break
                    }

                    verticalCandidateSentence.append(metaData)
                }
                rules.append(contentsOf: parse(sentence: verticalCandidateSentence))
                var horizontalCandidateSentence: [Classification] = []
                for k in j..<block[0].count {
                    guard let entityTypes = block[i][k],
                          let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                        break
                    }
                    horizontalCandidateSentence.append(metaData)
                }
                rules.append(contentsOf: parse(sentence: horizontalCandidateSentence))
            }
        }
        return rules
    }
}
