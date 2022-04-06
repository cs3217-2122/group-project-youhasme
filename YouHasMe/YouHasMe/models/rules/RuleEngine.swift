import Foundation

protocol RuleValidationStrategy {
    func validate(rules: [Rule], for entity: inout Entity, environment: LevelLayer)
}

protocol RuleEngineDelegate: ConditionEvaluableDungeonDelegate {}

class RuleEngine {
    weak var ruleEngineDelegate: RuleEngineDelegate? {
        didSet {
            let matchingStrategy = SouthwardEastwardMatchingStrategy()
            let parsingStrategy = MaximumLengthParsingStrategy()
            parsingStrategy.dungeonDelegate = ruleEngineDelegate
            self.ruleParser = RuleParser(
                sentenceMatchingStrategy: matchingStrategy,
                sentenceParsingStrategy: parsingStrategy
            )
        }
    }
    var wellFormedRules: [Rule] = []
    private var ruleParser: RuleParser
    private var ruleValidator: RuleValidationStrategy

    init() {
        let matchingStrategy = SouthwardEastwardMatchingStrategy()
        let parsingStrategy = MaximumLengthParsingStrategy()
        self.ruleParser = RuleParser(
            sentenceMatchingStrategy: matchingStrategy,
            sentenceParsingStrategy: parsingStrategy
        )
        self.ruleValidator = ConditionalRuleValidationStrategy()
    }

    init(ruleParser: RuleParser, ruleValidator: RuleValidationStrategy) {
        self.ruleParser = ruleParser
        self.ruleValidator = ruleValidator
    }

    // Adds behaviours to entities of levelLayer based on rules
    func applyRules(to levelLayer: LevelLayer) -> LevelLayer {
        let rules = ruleParser.parse(block: levelLayer.getAbstractRepresentation())
        var newLayer = levelLayer
        for y in 0..<newLayer.tiles.count {
            for x in 0..<newLayer.tiles[0].count {
                let point = Point(x: x, y: y)
                for i in 0..<newLayer.tiles[point].entities.count {
                    ruleValidator.validate(rules: rules, for: &newLayer.tiles[point].entities[i], environment: newLayer)
                }
            }
        }
        return newLayer
    }
}
