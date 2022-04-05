//
//  UnlockConditionUtil.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 4/4/22.
//

import Foundation

struct UnlockConditionUtil {
   static func fromPersistable(persistable: PersistableUnlockCondition) -> UnlockCondition {
       persistable.unlockCondition
   }
}
