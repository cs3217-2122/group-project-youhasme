import Foundation

enum Classification: Hashable {
    case noun(Noun)
    case verb(Verb)
    case connective(Connective)
    case property(Property)
    case nounInstance(Noun)
    case conditionRelation(ConditionRelation)
    case conditionEvaluable(ConditionEvaluable)
}

extension Classification {
    var isMetaData: Bool {
        if case .nounInstance = self {
            return false
        }
        return true
    }
}

extension Classification {
    func toPersistable() -> PersistableClassification {
        switch self {
        case .noun(let noun):
            return .noun(noun)
        case .verb(let verb):
            return .verb(verb)
        case .connective(let connective):
            return .connective(connective)
        case .property(let property):
            return .property(property)
        case .nounInstance(let noun):
            return .nounInstance(noun)
        case .conditionRelation(let conditionRelation):
            return .conditionRelation(conditionRelation)
        case .conditionEvaluable(let conditionEvaluable):
            return .conditionEvaluable(conditionEvaluable.toPersistable())
        }
    }

    static func fromPersistable(_ persistableClassification: PersistableClassification) -> Classification {
        switch persistableClassification {
        case .noun(let noun):
            return .noun(noun)
        case .verb(let verb):
            return .verb(verb)
        case .connective(let connective):
            return .connective(connective)
        case .property(let property):
            return .property(property)
        case .nounInstance(let noun):
            return .nounInstance(noun)
        case .conditionRelation(let conditionRelation):
            return .conditionRelation(conditionRelation)
        case .conditionEvaluable(let conditionEvaluable):
            return .conditionEvaluable(
                ConditionEvaluable.fromPersistable(conditionEvaluable)
            )
        }
    }
}
