import Foundation

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
