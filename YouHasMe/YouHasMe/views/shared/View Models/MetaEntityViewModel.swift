//
//  MetaEntityViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
import Combine

protocol EntityViewModelBasicCRUDDelegate: AnyObject {
    func addSelectedEntity(to worldPosition: Point)
    func removeEntity(from worldPosition: Point)
}

protocol EntityViewModelExaminableDelegate: AnyObject {
    func examineTile(at worldPosition: Point)
}

class EntityViewModel: CellViewModel {
    weak var basicCRUDDelegate: EntityViewModelBasicCRUDDelegate?
    weak var examinableDelegate: EntityViewModelExaminableDelegate?
    var tile: Tile?
    var worldPosition: Point?

    convenience init(tile: Tile?) {
        self.init(tile: tile, worldPosition: nil)
    }

    init(tile: Tile?, worldPosition: Point?) {
        self.tile = tile
        self.worldPosition = worldPosition

        guard let tile = tile else {
            super.init(imageSource: nil)
            return
        }

        if tile.entities.isEmpty {
            super.init(imageSource: .uiColor(.gray))
        } else {
            super.init(imageSource: entityTypeToImageable(type: tile.entities[0].entityType))
        }
    }

    func addEntity() {
        guard let delegate = basicCRUDDelegate, let worldPosition = worldPosition else {
            return
        }

        delegate.addSelectedEntity(to: worldPosition)
    }

    func removeEntity() {
        guard let delegate = basicCRUDDelegate, let worldPosition = worldPosition else {
            return
        }

        delegate.removeEntity(from: worldPosition)
    }

    func examine() {
        guard let delegate = examinableDelegate, let worldPosition = worldPosition else {
            return
        }

        delegate.examineTile(at: worldPosition)
    }
}
