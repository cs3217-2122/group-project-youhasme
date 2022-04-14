//
//  UnlockCondition.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 30/3/22.
//

import Foundation

protocol UnlockCondition {
    func isFulfilled() -> Bool
    func toPersistable() -> PersistableUnlockCondition
}
