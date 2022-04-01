//
//  BooleanUnlockCondition.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 30/3/22.
//

import Foundation

class BooleanUnlockCondition: UnlockCondition {
    var fulfilled = false

    init() {
    }

    func fulfil() {
        fulfilled = true
    }

    func isFulfilled() -> Bool {
        fulfilled
    }
}
