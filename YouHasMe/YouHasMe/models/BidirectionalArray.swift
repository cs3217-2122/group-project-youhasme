//
//  BidirectionalArray.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import Foundation
struct BidirectionalArray<T> {
    private var backingArray: [T] = []
    private func getActualIndex(_ index: Int) -> Int {
        index >= 0 ? backingArray[2 * index] : backingArray[2 * -index - 1]
    }
    
    func getAtIndex(_ index: Int) -> T {
        backingArray[getActualIndex(index)]
    }
    
    func setAtIndex(_: Int, value: T) {
        backingArray[getActualIndex(index)] = value
    }
    
    func append(_ item: T) {
        
    }
    
    func prepend(_ item: T) {
        
    }
}
