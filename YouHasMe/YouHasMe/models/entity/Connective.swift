import Foundation

enum Connective: String, Hashable {
    case and
}

extension Connective: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}
