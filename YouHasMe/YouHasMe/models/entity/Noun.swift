import Foundation

enum Noun: String, Hashable {
    case baba
    case wall
    case flag
    case skull
    case box
    case word
    case bedrock
    case connectorWall
}

extension Noun: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue
    }
}

extension Noun: Codable {}

extension Noun: CaseIterable {}
