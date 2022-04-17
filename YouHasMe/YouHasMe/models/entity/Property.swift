import Foundation

enum Property: String, Hashable {
    case you
    case win
    case stop
    case push
    case sink
}

extension Property: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}

extension Property: Codable {
}
