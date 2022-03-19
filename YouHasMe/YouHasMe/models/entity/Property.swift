import Foundation

enum Property: String, Hashable {
    case you
    case win
    case defeat
    case stop
    case push
    case pull
}

extension Property: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}
