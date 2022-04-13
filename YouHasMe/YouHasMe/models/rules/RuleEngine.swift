import Foundation
import Combine

protocol RuleValidationStrategy {
    func validate(rules: [Rule]) -> [Rule]
}

protocol RuleEngineDelegate: ConditionEvaluableDungeonDelegate {}

class RuleEngine {
    weak var ruleEngineDelegate: RuleEngineDelegate?
    private var ruleParser: RuleParser
    private var ruleValidator: RuleValidationStrategy
    private var ruleApplicator: RuleApplicator
    var lastActiveRulesPublisher: AnyPublisher<[Rule], Never> {
        lastActiveRulesSubject.eraseToAnyPublisher()
    }
    private var lastActiveRulesSubject: CurrentValueSubject<[Rule], Never> = CurrentValueSubject([])

    init(ruleEngineDelegate: RuleEngineDelegate?) {
        let matchingStrategy = SouthwardEastwardMatchingStrategy()
        let parsingStrategy = MaximumLengthParsingStrategy()
        parsingStrategy.dungeonDelegate = ruleEngineDelegate
        self.ruleParser = RuleParser(
            sentenceMatchingStrategy: matchingStrategy,
            sentenceParsingStrategy: parsingStrategy
        )
        self.ruleValidator = ConditionalRuleValidationStrategy()
        self.ruleApplicator = RuleApplicator()
    }

    // Adds behaviours to entities of levelLayer based on rules
    func applyRules(to levelLayer: LevelLayer) -> LevelLayer {
        let rules = ruleParser.parse(block: levelLayer.getAbstractRepresentation())
        var newLayer = levelLayer

        let activeRules = ruleValidator.validate(rules: rules)

        for y in 0..<newLayer.tiles.count {
            for x in 0..<newLayer.tiles[0].count {
                let point = Point(x: x, y: y)
                for i in 0..<newLayer.tiles[point].entities.count {
                    ruleApplicator.applyRules(
                        activeRules,
                        to: &newLayer.tiles[point].entities[i]
                    )
                }
            }
        }

        lastActiveRulesSubject.send(activeRules)
        return newLayer
    }
}
