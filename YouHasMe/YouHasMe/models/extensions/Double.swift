//
//  Double.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 22/3/22.
//

import Foundation
import Foundation

extension Double {

    /// A generalization of the modulus operation, usally denoted "A mod B",
    /// between an integer A and a non-zero integer B.
    ///
    /// - Parameter range: The numerical range, [0, range) that the result is to be capped to.
    /// - Returns: A number congruent to the `self` with respect to `range`.
    /// - Warning: `range` must be positive
    func generalizedMod(within range: Double) -> Double {
        assert(range > 0, "range must be positive")
        var val = self
        while val >= range {
            val -= range
        }

        while val < 0 {
            val += range
        }

        assert(0 <= val && val < range)
        return val
    }

    func signum() -> Int {
        if self > 0 {
            return 1
        } else if self < 0 {
            return -1
        } else {
            return 0
        }
    }

    func absoluteFloor() -> Int {
        signum() * Int(floor(Double(signum()) * self))
    }
}
