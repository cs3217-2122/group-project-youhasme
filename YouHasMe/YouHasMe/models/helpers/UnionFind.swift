//
//  UnionFind.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 10/4/22.
//

import Foundation
// taken from https://github.com/raywenderlich/swift-algorithm-club/blob/master/Union-Find/UnionFind.playground/Sources/UnionFindWeightedQuickUnionPathCompression.swift
public struct UnionFind<T: Hashable> {

    fileprivate var index = [T: Int]()
    fileprivate var parent = [Int]()
    fileprivate var size = [Int]()
    fileprivate var representatives = [T]()

    public init() {}

    public mutating func addSetWith(_ element: T) {
        index[element] = parent.count
        parent.append(parent.count)
        representatives.append(element)
        size.append(1)
    }

    /// Path Compression.
    private mutating func setByIndex(_ index: Int) -> Int {
        if index != parent[index] {
            parent[index] = setByIndex(parent[index])
        }
        return parent[index]
    }

    public mutating func setOf(_ element: T) -> Int? {
        if let indexOfElement = index[element] {
            return setByIndex(indexOfElement)
        } else {
            return nil
        }
    }

    public mutating func unionSetsContaining(_ firstElement: T, and secondElement: T) {
        if let firstSet = setOf(firstElement), let secondSet = setOf(secondElement) {
            if firstSet != secondSet {
                if size[firstSet] < size[secondSet] {
                    parent[firstSet] = secondSet
                    size[secondSet] += size[firstSet]
                } else {
                    parent[secondSet] = firstSet
                    size[firstSet] += size[secondSet]
                }
            }
        }
    }

    public mutating func inSameSet(_ firstElement: T, and secondElement: T) -> Bool {
        if let firstSet = setOf(firstElement), let secondSet = setOf(secondElement) {
            return firstSet == secondSet
        } else {
            return false
        }
    }
}

extension UnionFind {
    mutating func unionSetsContaining(representative: T, other: T) {
        if let firstSet = setOf(representative), let secondSet = setOf(other) {
            if firstSet != secondSet {
                if size[firstSet] < size[secondSet] {
                    parent[firstSet] = secondSet
                    size[secondSet] += size[firstSet]
                    representatives[secondSet] = representative
                } else {
                    parent[secondSet] = firstSet
                    size[firstSet] += size[secondSet]
                    representatives[firstSet] = representative
                }
            }
        }
    }

    mutating func isElementRepresentativeOfSet(_ element: T) -> Bool {
        guard let setIndex = setOf(element) else {
            fatalError("Element not found")
        }

        return representatives[setIndex] == element
    }
}
