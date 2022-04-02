//
//  Location.swift
//  YouHasMe
//
//  Created by wayne on 20/3/22.
//

struct Location: Hashable {
    var x: Int
    var y: Int
    var z: Int

    func isAt(x: Int, y: Int) -> Bool {
        self.x == x && self.y == y
    }

    func isOverlapping(with other: Location) -> Bool {
        isAt(x: other.x, y: other.y)
    }
}
