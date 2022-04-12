import Foundation

/// Encapsulates a strategy that naively accepts all rules.
class NaiveRuleValidationStrategy: RuleValidationStrategy {
    func validate(rules: [Rule]) -> [Rule] {
        rules
    }
}
