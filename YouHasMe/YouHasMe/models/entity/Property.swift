import Foundation

enum Property: Hashable {
    case you
    case win
    case stop
    case push
    case pull
    case player(Int)
    case sink
    case defeat
}

extension Property: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .you:
            return "you"
        case .win:
            return "win"
        case .defeat:
            return "defeat"
        case .stop:
            return "stop"
        case .push:
            return "push"
        case .pull:
            return "pull"
        case .player(let num):
            return "player\(num)"
        case .sink:
            return "sink"
        }
    }
}

extension Property: Codable {
}
