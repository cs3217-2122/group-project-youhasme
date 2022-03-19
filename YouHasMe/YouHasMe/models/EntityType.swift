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

enum Connective: String, Hashable {
    case and
}

extension Connective: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}

enum Verb: String, Hashable {
    case vIs
    case vHas
}

extension Verb: CustomDebugStringConvertible {
    var debugDescription: String {
        let s: String = self.rawValue
        let index: String.Index = s.index(s.startIndex, offsetBy: 1)
        return "\(s[index...])"
    }
}

enum Noun: String, Hashable {
    case baba
    case wall
    case flag
    case skull
}

extension Noun: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}

enum Property: String, Hashable {
    case you
    case win
    case defeat
    case block
}

extension Property: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}

class EntityType: Hashable {
    var classification: Classification
    
    /// A set of rules potentially applicable to this entity type, that may or may not be active.
    var rules: [Rule] = []
    
    fileprivate init(classification: Classification) {
        self.classification = classification
    }
    
    static func == (lhs: EntityType, rhs: EntityType) -> Bool {
        lhs.classification == rhs.classification
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(classification)
    }
}

struct EntityTypes {
    struct Nouns {
        static var baba = EntityType(classification: .noun(.baba))
        static var flag = EntityType(classification: .noun(.flag))
        static var wall = EntityType(classification: .noun(.wall))
        static var skull = EntityType(classification: .noun(.skull))
    }
    
    struct Verbs {
        static var vIs = EntityType(classification: .verb(.vIs))
        static var vHas = EntityType(classification: .verb(.vHas))
    }
    
    struct Properties {
        static var you = EntityType(classification: .property(.you))
        static var win = EntityType(classification: .property(.win))
        static var defeat = EntityType(classification: .property(.defeat))
        static var block = EntityType(classification: .property(.block))
    }
    
    struct Connectives {
        static var and = EntityType(classification: .connective(.and))
    }
}


