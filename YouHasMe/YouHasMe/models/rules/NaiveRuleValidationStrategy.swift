import Foundation

/// Encapsulates a strategy that naively applies all possible parsed rules to a target,
/// as long as the rule's receiver matches the entity type.
class NaiveRuleValidationStrategy: RuleValidationStrategy {
    func validate(rules: [Rule], for entity: inout Entity, environment: LevelLayer) {
        var behaviours: [Behaviour] = []
        switch entity.entityType.classification {
        case .noun, .verb, .connective, .property:
            for rule in rules {
                guard rule.receiver == .word else {
                    continue
                }
                behaviours.append(rule.activateToBehaviour())
            }
        case .nounInstance(let noun):
            for rule in rules {
                guard rule.receiver == noun else {
                    continue
                }
                behaviours.append(rule.activateToBehaviour())
            }
        default:
            break
        }

        entity.activeBehaviours = behaviours
    }
}
