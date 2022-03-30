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
}
