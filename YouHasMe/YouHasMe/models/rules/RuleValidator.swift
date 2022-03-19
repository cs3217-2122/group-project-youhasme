import Foundation

class RuleValidator {
    // TODO: environment is currently not needed
    func validate(rules: [Rule], for entity: inout Entity, environment: LevelLayer) {
        var behaviours: [Behaviour] = []
        switch entity.entityType.classification {
        case .noun(_), .verb(_), .connective(_), .property(_):
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
        }
        entity.activeBehaviours = behaviours
    }
}
