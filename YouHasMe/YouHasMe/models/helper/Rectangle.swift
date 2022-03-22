import Foundation

struct Rectangle {
    var width: Int
    var height: Int
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

extension Rectangle: Codable, Equatable {}

// MARK: Grid specific functionality
extension Rectangle {
    var numCells: Int {
        width * height
    }
}

struct PositionedRectangle {
    private var rectangle: Rectangle
    var topLeft: Point
    var width: Int {
        get {
            rectangle.width
        }
        set {
            rectangle.width = newValue
        }
    }
    var height: Int {
        get {
            rectangle.height
        }
        set {
            rectangle.height = newValue
        }
    }
}

extension PositionedRectangle {
    var topSide: Int {
        topLeft.y
    }
    
    var bottomSide: Int {
        topLeft.y + height
    }
    
    var leftSide: Int {
        topLeft.x
    }
    
    var rightSide: Int {
        topLeft.x + width
    }
    
    var topRight: Point {
        Point(x: rightSide, y: topSide)
    }
    
    var bottomLeft: Point {
        Point(x: leftSide, y: bottomSide)
    }
    
    var bottomRight: Point {
        Point(x: rightSide, y: bottomSide)
    }
}


