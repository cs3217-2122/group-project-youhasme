import Foundation
import CoreGraphics

struct Vector {
    var dx: Int
    var dy: Int
}

extension Vector: CustomDebugStringConvertible {
    var debugDescription: String {
        "V(\(dx), \(dy))"
    }
}

extension Vector: Codable {}

extension Vector: Hashable {}

extension Vector {
    static var zero = Vector(dx: 0, dy: 0)

    static func fromPoint(_ point: Point) -> Vector {
        Vector(dx: point.x, dy: point.y)
    }

    func toPositionVector() -> Point {
        Point(x: dx, y: dy)
    }

    func add(with vector: Vector) -> Vector {
        Vector(dx: dx + vector.dx, dy: dy + vector.dy)
    }

    func addX(dx: Int) -> Vector {
        Vector(dx: self.dx + dx, dy: dy)
    }

    func addY(dy: Int) -> Vector {
        Vector(dx: dx, dy: self.dy + dy)
    }

    func reflect() -> Vector {
        Vector(dx: -dx, dy: -dy)
    }

    func reflectX() -> Vector {
        Vector(dx: -dx, dy: dy)
    }

    func reflectY() -> Vector {
        Vector(dx: dx, dy: -dy)
    }
}
