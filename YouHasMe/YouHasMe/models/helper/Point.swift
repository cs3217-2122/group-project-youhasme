import Foundation

struct Point {
    var x: Int
    var y: Int
}

extension Point {
    static var zero: Point = Point(x: 0, y: 0)
    
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

struct Vector {
    var dx: Int
    var dy: Int
}

extension Vector {
    static var zero: Vector = Vector(dx: 0, dy: 0)
    
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
