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
}
