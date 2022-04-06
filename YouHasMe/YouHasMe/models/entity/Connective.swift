import Foundation

enum Connective: String, Hashable {
    case and
    case cIf = "if"
    case not
}

extension Connective: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}

extension Connective: Codable {}
