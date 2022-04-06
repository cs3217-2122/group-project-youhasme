//
//  PersistableConditionEvaluable.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
struct PersistableConditionEvaluable {
    var evaluableType: PersistableConditionEvaluableType
}
extension PersistableConditionEvaluable: Codable {}

enum PersistableConditionEvaluableType {
    case dungeon(evaluatingKeyPath: PersistableNamedKeyPath)
    case level(id: Point, evaluatingKeyPath: PersistableNamedKeyPath)
    case player
    case numericLiteral(Int)
}

extension PersistableConditionEvaluableType: Codable {}
