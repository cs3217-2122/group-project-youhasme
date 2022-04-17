import Foundation

enum Property: Hashable {
    case you
    case win
    case stop
    case push
    case player(Int)
    case sink
}

extension Property: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .you:
            return "you"
        case .win:
            return "win"
        case .stop:
            return "stop"
        case .push:
            return "push"
        case .player(let num):
            return "player\(num)"
        case .sink:
            return "sink"
        }
    }
}

extension Property: Codable {
}
