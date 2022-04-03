import Foundation

enum Noun: String, Hashable {
    case baba
    case wall
    case flag
    case skull
    case box
    case word
}

extension Noun: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}

extension Noun: Codable {
}
