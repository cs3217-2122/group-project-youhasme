import Foundation

struct DefaultRules {
    static let rules = [
        Rule(receiver: .word, verb: .vIs, performer: .property(.push))
    ]
}
