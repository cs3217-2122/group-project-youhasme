//
//  MetaLevelDesignerTileInfoViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation

class MetaLevelDesignerTileInfoViewModel: ObservableObject {
    var tile: MetaTile
    var metaEntities: [MetaEntityType] {
        tile.metaEntities
    }

    init(tile: MetaTile) {
        self.tile = tile
    }

    func getMetaEntityViewModel() -> MetaEntityViewModel {
        MetaEntityViewModel(tile: tile, worldPosition: .zero)
    }

    func getConditionCreatorViewModel(with entityIndex: Int) -> ConditionCreatorViewModel {
        ConditionCreatorViewModel(entityIndex: entityIndex)
    }
}

extension MetaLevelDesignerTileInfoViewModel: ConditionCreatorViewModelDelegate {
    func saveCondition(_ condition: Condition, entityIndex: Int) {
        guard case let .level(levelLoadable: levelLoadable, unlockCondition: _) = metaEntities[entityIndex] else {
            return
        }

        tile.metaEntities[entityIndex] = .level(levelLoadable: levelLoadable, unlockCondition: condition)
    }
}
