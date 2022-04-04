//
//  CaseIterable.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 31/3/22.
//

import Foundation
extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        Self.allCases.firstIndex { self == $0 }
    }
}
