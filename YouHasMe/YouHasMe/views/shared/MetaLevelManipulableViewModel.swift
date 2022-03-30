//
//  MetaLevelManipulableViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation
protocol MetaLevelManipulableViewModel: IntegerViewTranslatable, ObservableObject {
    var currMetaLevel: MetaLevel { get set }
    func getTile(at viewOffset: Vector) -> MetaTile?
    func setTile(_ tile: MetaTile, at viewOffset: Vector)
}

extension MetaLevelManipulableViewModel {
    func getTile(at viewOffset: Vector) -> MetaTile? {
        currMetaLevel.getTile(
            at: viewPosition.translate(by: viewOffset),
            createChunkIfNotExists: true
        )
    }

    func setTile(_ tile: MetaTile, at viewOffset: Vector) {
        currMetaLevel.setTile(tile, at: getWorldPosition(at: viewOffset))
    }
}
