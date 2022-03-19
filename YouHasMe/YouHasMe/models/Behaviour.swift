import Foundation

enum Behaviour: Equatable {
    case property(Property)
    case bIs(Noun)
    case bHas(Noun)
}

extension Behaviour: Codable {
}
