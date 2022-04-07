import Foundation
import CoreGraphics

struct Point {
    var x: Int
    var y: Int
}

extension Point: CustomStringConvertible {
    var description: String {
        "(\(x), \(y))"
    }
}

extension Point: Comparable {
    static func < (lhs: Point, rhs: Point) -> Bool {
        guard lhs.y != rhs.y else {
            return lhs.x < rhs.x
        }
        return lhs.y < rhs.y
    }
}

extension Point: Codable {}

extension Point: Hashable {}

extension Point {
    static var zero = Point(x: 0, y: 0)

    static func fromVector(_ vector: Vector) -> Point {
        Point(x: vector.dx, y: vector.dy)
    }

    func toVector() -> Vector {
        Vector(dx: x, dy: y)
    }

    func translate(by vector: Vector) -> Point {
        Point(x: x + vector.dx, y: y + vector.dy)
    }

    func translateX(dx: Int) -> Point {
        Point(x: x + dx, y: y)
    }

    func translateY(dy: Int) -> Point {
        Point(x: x, y: y + dy)
    }
}

extension Point: DataStringConvertible {
    var dataString: String {
        "\(x)_\(y)"
    }
}

extension Point: CustomDebugStringConvertible {
    var debugDescription: String {
        "P(\(x), \(y))"
    }
}
