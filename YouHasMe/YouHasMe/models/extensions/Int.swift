//
//  Int.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 24/3/22.
//

import Foundation
extension Int {
    func flooredDiv(_ other: Int) -> Int {
        Int(floor(Double(self) / Double(other)))
    }

    func modulo(_ residualClass: Int) -> Int {
        assert(residualClass > 0)
        let remainder = self % residualClass
        return remainder >= 0 ? remainder : remainder + residualClass
    }

    var isEven: Bool {
        self.isMultiple(of: 2)
    }

    var isOdd: Bool {
        !isEven
    }
}
