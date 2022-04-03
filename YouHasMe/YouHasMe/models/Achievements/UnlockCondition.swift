//
//  UnlockCondition.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 30/3/22.
//

import Foundation

protocol UnlockCondition {
    func isFulfilled() -> Bool
//    func toPersistable() -> PersistableUnlockCondition
}

// public struct PersistableUnlockCondition: Codable {
//    private enum CodingKeys: String, CodingKey {
//        case conditionType
//        case condition
//    }
//
//    enum ConditionType: Int, Codable {
//        case integer
//    }
//
//    var conditionType: ConditionType
//    var unlockCondition: UnlockCondition
//
//    init(conditionType: ConditionType, condition: UnlockCondition) {
//        self.conditionType = conditionType
//        self.unlockCondition = condition
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let conditionType = try container.decode(ConditionType.self, forKey: .conditionType)
//
//        switch conditionType {
//        case .integer:
//            self.conditionType = try container.decode(ConditionType.self, forKey: .conditionType)
//            self.unlockCondition = try container.decode(IntegerUnlockCondition.self, forKey: .condition)
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        switch unlockCondition {
//        case let condition as IntegerUnlockCondition:
//            try container.encode(ConditionType.integer, forKey: .conditionType)
//            try container.encode(condition, forKey: .condition)
//        default:
//            break
//        }
//    }
// }
