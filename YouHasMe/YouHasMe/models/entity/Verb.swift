import Foundation

enum Verb: String, Hashable {
    case vIs
    case vHas
}

extension Verb: CustomDebugStringConvertible {
    var debugDescription: String {
        let s: String = self.rawValue
        let index: String.Index = s.index(s.startIndex, offsetBy: 1)
        return "\(s[index...])"
    }
}
