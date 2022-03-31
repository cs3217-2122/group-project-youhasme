//
//  LevelInfoViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 31/3/22.
//

import Foundation
import Combine

class LevelInfoViewModel: ObservableObject {
    struct LevelInfoWithConditions {
        var level: Level
        var unlockCondition: Condition?
    }

    @Published var levelInfo: [LevelInfoWithConditions] = []

    private var subscriptions: Set<AnyCancellable> = []

    init(tile: MetaTile) {
        let levelStorage = LevelStorage()
        tile.$metaEntities.sink { [weak self] metaEntities in
            self?.levelInfo = metaEntities.compactMap { (metaEntity: MetaEntityType) -> LevelInfoViewModel.LevelInfoWithConditions? in
                guard case let .level(
                    levelLoadable: levelLoadable,
                    unlockCondition: unlockCondition
                ) = metaEntity,
                    let levelLoadable = levelLoadable,
                      let level = levelStorage.loadLevel(name: levelLoadable.name)
                else {
                    return nil
                }
                return LevelInfoWithConditions(level: level, unlockCondition: unlockCondition)
            }
        }.store(in: &subscriptions)
    }
}
