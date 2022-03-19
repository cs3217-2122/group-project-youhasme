import Foundation

class RuleValidator {
    // TODO: environment is currently not needed
    func validate(rules: [Rule], for entity: inout Entity, environment: LevelLayer) {
        var behaviours: [Behaviour] = []
        for rule in rules {
            behaviours.append(rule.activateToBehaviour())
        }
        entity.activeBehaviours = behaviours
    }
}
