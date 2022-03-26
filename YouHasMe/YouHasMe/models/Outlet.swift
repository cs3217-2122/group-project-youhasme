import Foundation
protocol OutletDelegate: AnyObject {
    var dimensions: Rectangle { get }
}

enum RectangleEdge {
    case topEdge
    case bottomEdge
    case leftEdge
    case rightEdge
}

extension RectangleEdge: Codable {}

final class Outlet {
    var condition: Condition?
    var connector: Connector?
    // outlet lies on the boundaries
    var edge: RectangleEdge
    var position: ClosedRange<Int>

    var isOpen: Bool {
        condition?.isConditionMet() ?? true
    }

    init(edge: RectangleEdge, position: ClosedRange<Int>) {
        self.edge = edge
        self.position = position
    }
}
