import Foundation

typealias EntityBlock = [[Set<Classification>?]]

struct Rule {
    enum RulePerformer: Hashable {
        case noun(Noun)
        case property(Property)
    }

    var receiver: Noun
    var verb: Verb
    var performer: RulePerformer
    var conditions: [Condition] = []
    var relevantEntities: [EntityType] = []
    init(receiver: Noun, verb: Verb, performer: RulePerformer) {
        self.receiver = receiver
        self.verb = verb
        self.performer = performer
    }

    func activateToBehaviour() -> Behaviour {
        switch performer {
        case .noun(let noun):
            switch verb {
            case .vIs:
                return .bIs(noun)
            case .vHas:
                return .bHas(noun)
            }
        case .property(let property):
            return .property(property)
        }
    }
}

extension Rule: Hashable {
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        lhs.receiver == rhs.receiver && lhs.verb == rhs.verb && lhs.performer == rhs.performer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(receiver)
        hasher.combine(verb)
        hasher.combine(performer)
    }
}

extension Rule.RulePerformer: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .noun(let item as CustomDebugStringConvertible), .property(let item as CustomDebugStringConvertible):
            return item.debugDescription
        default:
            return ""
        }
    }
}

extension Rule: CustomStringConvertible {
    var description: String {
        debugDescription
    }
}

extension Rule: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        \(receiver.debugDescription) \(verb.debugDescription) \(performer.debugDescription)
        """
    }
}
