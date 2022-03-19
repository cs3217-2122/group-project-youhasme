import Foundation
enum EntityType: Hashable {
    case noun(Noun)
    case verb(Verb)
    case connective(Connective)
    case property(Property)
    case nounInstance(Noun)
}

extension EntityType {
    var isMetaData: Bool {
        if case .nounInstance(_) = self {
            return false
        }
        return true
    }
}

enum Connective: Hashable {
    case and
}

enum Verb: Hashable {
    case vIs
    case vHas
}

enum Noun: Hashable {
    case baba
    case wall
    case flag
    case skull
}

enum Property: Hashable {
    case you
    case win
    case defeat
    case block
    case equalTo(Noun)
}


class Entity {
    var classification: EntityType
    var rules: [Rule] = []
    
    init(classification: EntityType) {
        self.classification = classification
    }
}
