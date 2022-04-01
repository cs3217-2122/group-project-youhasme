//
//  NumericStatistic.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 31/3/22.
//

import Foundation

class GameStatistic: Codable, Hashable {
    var id: Int
    var name: String
    var value: Int

    init(id: Int, name: String, value: Int) {
        self.id = id
        self.name = name
        self.value = value
    }

    func increase() {
        value += 1
        print("\(name) increased to \(value)")
    }

    func reset() {
        value = 0
    }

    static func == (lhs: GameStatistic, rhs: GameStatistic) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
