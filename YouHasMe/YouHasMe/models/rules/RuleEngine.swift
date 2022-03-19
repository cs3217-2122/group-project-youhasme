import Foundation

class RuleEngine {
    var wellFormedRules: [Rule] = []
    private var ruleParser = RuleParser()
    private var ruleValidator = RuleValidator()
}
