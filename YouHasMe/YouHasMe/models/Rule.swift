//
//  Rule.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import Foundation

typealias EntityBlock = [[Set<EntityType>?]]



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
        var dfaState: AutomataState = .epsilon
        var receivers: [Noun] = []
        var properties: [Property] = []
        var hasObjects: [Noun] = []
        
        func getRules() -> [Rule] {
            var rules: [Rule] = []
            for noun in receivers {
                for property in properties {
                    rules.append(Rule(receiver: noun, verb: .vIs, performer: .property(property)))
                }
                for otherNoun in hasObjects {
                    rules.append(Rule(receiver: noun, verb: .vHas, performer: .noun(otherNoun)))
                }
            }
            return rules
        }
    }
    
    
    func transition(ruleParserState: RuleParserState, entityType: EntityType) {
        switch ruleParserState.dfaState {
        case .epsilon:
            switch entityType {
            case .noun(let noun):
                ruleParserState.receivers.append(noun)
                ruleParserState.dfaState = .noun
                return
            default:
                break
            }
        case .noun:
            switch entityType {
            case .verb(let verb):
                switch verb {
                case .vIs:
                    ruleParserState.dfaState = .isVerb
                case .vHas:
                    ruleParserState.dfaState = .hasVerb
                }
                return
            case .connective(let connectiveType) where connectiveType == .and:
                ruleParserState.dfaState = .noun_concat_and
                return
            default:
                break
            }

        case .noun_concat_and:
            if case .noun(let noun) = entityType {
                ruleParserState.receivers.append(noun)
                ruleParserState.dfaState = .noun
                return
            }
        case .isVerb:
            switch entityType {
            case .noun(let noun):
                ruleParserState.properties.append(.equalTo(noun))
                ruleParserState.dfaState = .isVerb_concat_nounProp
                return
            case .property(let property):
                ruleParserState.properties.append(property)
                ruleParserState.dfaState = .isVerb_concat_nounProp
                return
            default:
                break
            }
        case .isVerbPrime:
            switch entityType {
            case .noun(let noun):
                ruleParserState.properties.append(.equalTo(noun))
                ruleParserState.dfaState = .isVerb_concat_nounProp
                return
            case .property(let property):
                ruleParserState.properties.append(property)
                ruleParserState.dfaState = .isVerb_concat_nounProp
                return
            case .verb(let verbType) where verbType == .vHas:
                ruleParserState.dfaState = .hasVerb
                return
            default:
                break
            }
        case .isVerb_concat_nounProp:
            if case .connective(let connective) = entityType, connective == .and {
                ruleParserState.dfaState = .isVerbPrime
                return
            }
        case .hasVerb:
            switch entityType {
            case .noun(let noun):
                ruleParserState.hasObjects.append(noun)
                ruleParserState.dfaState = .hasVerb_concat_noun
                return
            default:
                break
            }
        case .hasVerbPrime:
            switch entityType {
            case .noun(let noun):
                ruleParserState.hasObjects.append(noun)
                ruleParserState.dfaState = .hasVerb_concat_noun
                return
            case .verb(let verb) where verb == .vIs:
                ruleParserState.dfaState = .isVerb
                return
            default:
                break
            }
        case .hasVerb_concat_noun:
            switch entityType {
            case .connective(let connective) where connective == .and:
                ruleParserState.dfaState = .hasVerbPrime
                return
            default:
                break
            }
        case .reject:
            break
        }
        ruleParserState.dfaState = .reject
    }
    
    func parse(sentence: [EntityType]) -> [Rule] {
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
                
                var verticalCandidateSentence: [EntityType] = []
                for k in i..<block.count {
                    guard let entityTypes = block[k][j],
                          let metaData = entityTypes.first(where: { $0.isMetaData }) else {
                        break
                    }
                    
                    verticalCandidateSentence.append(metaData)
                }
                rules.append(contentsOf: parse(sentence: verticalCandidateSentence))
                var horizontalCandidateSentence: [EntityType] = []
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

class RuleValidator {
    
}


class RuleEngine {
    var wellFormedRules: [Rule] = []
    private var ruleParser: RuleParser = RuleParser()
    private var ruleValidator: RuleValidator = RuleValidator()
}

enum RulePerformer: Hashable {
    case noun(Noun)
    case property(Property)
}

class Rule {
    var receiver: Noun
    var verb: Verb
    var perfomer: RulePerformer
    var relevantEntities: [Entity] = []
    init(receiver: Noun, verb: Verb, performer: RulePerformer) {
        self.receiver = receiver
        self.verb = verb
        self.perfomer = performer
    }
}

extension Rule: Hashable {
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        return lhs.receiver == rhs.receiver && lhs.verb == rhs.verb && lhs.perfomer == rhs.perfomer
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(receiver)
        hasher.combine(verb)
        hasher.combine(perfomer)
    }
}
