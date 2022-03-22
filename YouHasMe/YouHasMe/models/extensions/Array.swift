import Foundation
extension Array {
    /// A variant of `init(repeating:count:)`, that fills an array to the given `count` with the result produced
    /// by `repeatingFactory`.
    ///
    /// - Parameters:
    ///   - repeatingFactory: A function producing a certain object of type `Element`.
    ///   - count: The number of times to invoke `repeatingFactory`, so that the array is of size `count`.
    init(repeatingFactory: @autoclosure () -> Element, count: Int) {
        self = []
        for _ in 0..<count {
            self.append(repeatingFactory())
        }
    }
}

extension Array where Element: Equatable {
    mutating func removeAll(_ item: Element) {
        removeAll(where: { $0 == item })
    }
}

extension Array where Element: AnyObject {
    mutating func removeByIdentity(_ item: Element) {
        removeAll(where: { $0 === item })
    }
}

// Random
extension Array {
    static func getRandomPermutation(in range: Range<Int>) -> [Int] {
        var arr = [Int](range)
        arr.shuffle()
        return arr
    }
}
