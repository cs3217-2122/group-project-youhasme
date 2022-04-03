import Foundation

protocol RuleValidationStrategy {
    func validate(rules: [Rule], for entity: inout Entity, environment: LevelLayer)
}

class RuleEngine {
    var wellFormedRules: [Rule] = []
    private var ruleParser: RuleParser
    private var ruleValidator: RuleValidationStrategy

    init() {
        self.ruleParser = RuleParser(
            sentenceMatchingStrategy: SouthwardEastwardMatchingStrategy(),
            sentenceParsingStrategy: MaximumLengthParsingStrategy()
        )
        self.ruleValidator = NaiveRuleValidationStrategy()
    }

    init(ruleParser: RuleParser, ruleValidator: RuleValidationStrategy) {
        self.ruleParser = ruleParser
        self.ruleValidator = ruleValidator
    }

    // Adds behaviours to entities of levelLayer based on rules
    func applyRules(to levelLayer: LevelLayer) -> LevelLayer {
        let rules = ruleParser.parse(block: levelLayer.getAbstractRepresentation())
        var newLayer = levelLayer
        for i in 0..<newLayer.tiles.count {
            for j in 0..<newLayer.tiles[i].entities.count {
                ruleValidator.validate(rules: rules, for: &newLayer.tiles[i].entities[j], environment: newLayer)
            }
        }
        return newLayer
    }
}
