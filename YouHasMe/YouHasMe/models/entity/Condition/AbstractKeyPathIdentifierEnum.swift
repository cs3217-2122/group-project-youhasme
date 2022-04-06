//
//  AbstractKeyPathIdentifierEnum.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
protocol AbstractKeyPathIdentifierEnum: Codable,
    Hashable,
    CustomStringConvertible,
    CaseIterable,
    RawRepresentable where Self.RawValue == String {}
extension AbstractKeyPathIdentifierEnum {
    static func getEnumByString(_ str: String) -> Self {
        guard let value = allCases.first(where: { $0.description == str }) else {
            fatalError("should not be nil")
        }
        return value
    }

    var description: String {
        rawValue
    }
}
