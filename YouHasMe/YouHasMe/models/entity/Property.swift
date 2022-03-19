import Foundation

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
