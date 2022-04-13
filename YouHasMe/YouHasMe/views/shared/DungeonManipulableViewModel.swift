//
//  MetaLevelManipulableViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation
protocol DungeonManipulableViewModel: IntegerViewTranslatable, ObservableObject {
    var dungeon: Dungeon { get set }
    func getTile(at viewOffset: Vector, loadNeighboringChunks: Bool) -> Tile?
    func setTile(_ tile: Tile, at viewOffset: Vector)
}

extension DungeonManipulableViewModel {
    func getTile(at viewOffset: Vector, loadNeighboringChunks: Bool) -> Tile? {
        dungeon.getTile(
            at: getWorldPosition(at: viewOffset),
            loadNeighboringLevels: loadNeighboringChunks
        )
    }

    func setTile(_ tile: Tile, at viewOffset: Vector) {
        dungeon.setTile(tile, at: getWorldPosition(at: viewOffset))
    }
}
