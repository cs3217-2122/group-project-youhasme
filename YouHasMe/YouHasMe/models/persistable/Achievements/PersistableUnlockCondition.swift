//
//  PersistableUnlockCondition.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 4/4/22.
//

import Foundation

struct PersistableUnlockCondition: Codable {
    private enum CodingKeys: String, CodingKey {
        case conditionType
        case unlockCondition
    }

    enum ConditionType: Int, Codable {
        case integer
    }

    var conditionType: ConditionType
    var unlockCondition: UnlockCondition

    init(conditionType: ConditionType, unlockCondition: UnlockCondition) {
        self.conditionType = conditionType
        self.unlockCondition = unlockCondition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let conditionType = try container.decode(ConditionType.self, forKey: .conditionType)

        switch conditionType {
        case .integer:
            self.conditionType = try container.decode(ConditionType.self, forKey: .conditionType)
            self.unlockCondition = try container.decode(PersistableIntegerUnlockCondition.self,
                                                        forKey: .unlockCondition)
                .toIntegerUnlockCondition()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch unlockCondition {
        case let unlockCondition as IntegerUnlockCondition:
            try container.encode(ConditionType.integer, forKey: .conditionType)
            try container.encode(unlockCondition.toPersistable(), forKey: .unlockCondition)
        default:
            break
        }
    }
}
