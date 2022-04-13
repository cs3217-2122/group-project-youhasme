import Foundation

enum Connective: String, Hashable {
    case and
    case cIf = "if"
}

extension Connective: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}

extension Connective: Codable {}
