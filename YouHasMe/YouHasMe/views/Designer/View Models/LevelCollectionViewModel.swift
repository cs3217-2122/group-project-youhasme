//
//  LevelCollectionViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 7/4/22.
//

import Foundation
import CoreGraphics
import Combine

protocol LevelCollectionViewModelDelegate: AnyObject {
    func renameLevel(with oldName: String, to newName: String)
}

class LevelCollectionViewModel: ObservableObject {
    weak var delegate: LevelCollectionViewModelDelegate?
    var dungeonDimensions: Rectangle
    @Published var levelMetadata: [LevelMetadata] = []

    private var levelNameToPositionMapPublisher: AnyPublisher<[String: Point], Never>
    private var subscriptions: Set<AnyCancellable> = []
    var itemsPerRow: CGFloat {
        CGFloat(dungeonDimensions.width)
    }

    init(dungeonDimensions: Rectangle, levelNameToPositionMapPublisher: AnyPublisher<[String: Point], Never>) {
        self.dungeonDimensions = dungeonDimensions
        self.levelNameToPositionMapPublisher = levelNameToPositionMapPublisher
        setupBindings()
    }

    func setupBindings() {
        levelNameToPositionMapPublisher.sink { [weak self] levelNameToPositionMap in
            guard let self = self else {
                return
            }
            self.levelMetadata = LevelMetadata.levelNameToPositionMapToMetadata(levelNameToPositionMap)
        }.store(in: &subscriptions)
    }

    func renameLevel(with oldName: String, to newName: String) {
        guard let delegate = delegate else {
            return
        }

        delegate.renameLevel(with: oldName, to: newName)
    }
}
