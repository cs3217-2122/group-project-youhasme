import Foundation

enum Classification: Hashable {
    case noun(Noun)
    case verb(Verb)
    case connective(Connective)
    case property(Property)
    case nounInstance(Noun)
}

extension Classification {
    var isMetaData: Bool {
        if case .nounInstance(_) = self {
            return false
        }
        return true
    }
}
