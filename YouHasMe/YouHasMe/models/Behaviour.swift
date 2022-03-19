import Foundation

struct Behaviour {
    enum BehaviourTarget: Hashable {
        case noun(Noun)
        case property(Property)
    }
    var verb: Verb
    var target: BehaviourTarget
}
