import Foundation
struct BidirectionalArray<T: Codable> {
    private var lowerBound: Int = 0
    private var upperBound: Int = 0
    private var backingArray: [T?] = []
    private func getActualIndex(_ index: Int) -> Int {
        index >= 0 ? 2 * index : 2 * -index - 1
    }
    
    func getAtIndex(_ index: Int) -> T? {
        backingArray[getActualIndex(index)]
    }
    
    mutating func setAtIndex(_ index: Int, value: T) {
        let index = getActualIndex(index)
        while index >= backingArray.count {
            backingArray.append(nil)
        }

        backingArray[index] = value
    }
    
    mutating func append(_ item: T) {
        setAtIndex(upperBound, value: item)
        upperBound += 1
    }
    
    mutating func prepend(_ item: T) {
        lowerBound -= 1
        setAtIndex(lowerBound, value: item)
    }
}

extension BidirectionalArray: Codable {
}
