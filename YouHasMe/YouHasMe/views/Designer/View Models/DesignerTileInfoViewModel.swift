//
//  MetaLevelDesignerTileInfoViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation

class DesignerTileInfoViewModel: ObservableObject {
    var tile: Tile

    init(tile: Tile) {
        self.tile = tile
    }

    func getTileViewModel() -> EntityViewModel {
        EntityViewModel(tile: tile, worldPosition: .zero)
    }
}
