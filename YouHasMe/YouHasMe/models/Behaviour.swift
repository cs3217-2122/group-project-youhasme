import Foundation

enum Behaviour: Hashable {
    case property(Property)
    case bIs(Noun)
    case bHas(Noun)
}

extension Behaviour: Codable {
}
