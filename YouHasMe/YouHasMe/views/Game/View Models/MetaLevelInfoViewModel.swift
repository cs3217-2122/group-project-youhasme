//
//  MetaLevelInfoViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
import Combine
class MetaLevelInfoViewModel: ObservableObject {
    struct MetaLevelInfoWithConditions {
        var loadable: Loadable
        var metaLevel: MetaLevel
        var unlockCondition: Condition?
        var isLevelUnlocked: Bool {
            guard let unlockCondition = unlockCondition else {
                return true
            }

            return unlockCondition.isConditionMet()
        }
    }

    @Published var metaLevelInfo: [MetaLevelInfoWithConditions] = []

    private var subscriptions: Set<AnyCancellable> = []

    init(tile: MetaTile) {
        let metaLevelStorage = MetaLevelStorage()
        tile.$metaEntities.sink { [weak self] metaEntities in
            self?.metaLevelInfo = metaEntities.compactMap { (metaEntity: MetaEntityType) -> MetaLevelInfoViewModel.MetaLevelInfoWithConditions? in
                guard case let .travel(
                    metaLevelLoadable: metaLevelLoadable,
                    unlockCondition: unlockCondition
                ) = metaEntity,
                    let metaLevelLoadable = metaLevelLoadable,
                      let metaLevel = metaLevelStorage.loadMetaLevel(name: metaLevelLoadable.name)
                else {
                    return nil
                }
                return MetaLevelInfoWithConditions(loadable: metaLevelLoadable, metaLevel: metaLevel, unlockCondition: unlockCondition)
            }
        }.store(in: &subscriptions)
    }
}

extension MetaLevelInfoViewModel.MetaLevelInfoWithConditions: Identifiable {
    var id: ObjectIdentifier {
        metaLevel.id
    }
}
