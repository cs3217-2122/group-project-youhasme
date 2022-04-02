import Foundation


class RuleEngine {
    var wellFormedRules: [Rule] = []
    private var ruleParser = RuleParser(
        sentenceMatchingStrategy: MaximumLengthMatchingStrategy(),
        sentenceParsingStrategy: DeterministicFiniteAutomaton()
    )
    
    private var ruleValidator = RuleValidator()
    
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
