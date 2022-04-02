//
//  MetaEntityViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
import Combine

protocol MetaEntityViewModelBasicCRUDDelegate: AnyObject {
    func addSelectedEntity(to tile: MetaTile)
    func removeEntity(from tile: MetaTile)
}

protocol MetaEntityViewModelDetailedUpdateDelegate: AnyObject {
    func examineTile(_ tile: MetaTile)
}

protocol MetaEntityViewModelLevelDelegate: AnyObject {
    func getLevelInfo(_ loadable: Loadable)
    func enterLevel(_ loadable: Loadable)
}

class MetaEntityViewModel: CellViewModel {
    weak var basicCRUDDelegate: MetaEntityViewModelBasicCRUDDelegate?
    weak var detailedUpdateDelegate: MetaEntityViewModelDetailedUpdateDelegate?
    weak var levelDelegate: MetaEntityViewModelLevelDelegate?
    var tile: MetaTile?
    var worldPosition: Point?

    private var subscriptions: Set<AnyCancellable> = []

    convenience init(tile: MetaTile?) {
        self.init(tile: tile, worldPosition: nil)
    }

    init(tile: MetaTile?, worldPosition: Point?) {
        self.tile = tile
        self.worldPosition = worldPosition

        guard let tile = tile else {
            super.init()
            return
        }

        if tile.metaEntities.isEmpty {
            super.init()
        } else {
            // TODO: Allow stacking of multiple images
            super.init(imageSource: metaEntityTypeToImageable(type: tile.metaEntities[0]))
        }
        setupBindings()
    }

    private func setupBindings() {
        guard let tile = tile else {
            return
        }

        tile.$metaEntities.sink { [weak self] metaEntities in
            guard !metaEntities.isEmpty else {
                self?.imageSource = nil
                return
            }
            self?.imageSource = metaEntityTypeToImageable(type: metaEntities[0])
        }
        .store(in: &subscriptions)
    }

    func addEntity() {
        guard let delegate = basicCRUDDelegate, let tile = tile else {
            return
        }

        delegate.addSelectedEntity(to: tile)
    }

    func removeEntity() {
        guard let delegate = basicCRUDDelegate, let tile = tile else {
            return
        }

        delegate.removeEntity(from: tile)
    }

    func examine() {
        guard let delegate = detailedUpdateDelegate, let tile = tile else {
            return
        }

        delegate.examineTile(tile)
    }

    func enterLevelIfExists() {
        guard
            let levelDelegate = levelDelegate,
            let tile = tile,
            let levelLoadable = tile.getLevelLoadable()
            else {
            return
        }

        levelDelegate.enterLevel(levelLoadable)
    }
}
