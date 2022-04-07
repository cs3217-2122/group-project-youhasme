//
//  LevelCollectionViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 7/4/22.
//

import Foundation
import CoreGraphics
import Combine

struct LevelMetadata: Identifiable {
    var id: Point
    var name: String
}

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
            self.levelNameToPositionMapToMetadata(levelNameToPositionMap)
        }.store(in: &subscriptions)
    }

    private func levelNameToPositionMapToMetadata(_ levelNameToPositionMap: [String: Point]) {
        levelMetadata = levelNameToPositionMap.sorted(by: { entry1, entry2 in
            let (_, value1) = entry1
            let (_, value2) = entry2
            return value1 < value2
        }).map { (levelName: String, levelPosition: Point) in
            LevelMetadata(id: levelPosition, name: levelName)
        }
    }

    func renameLevel(with oldName: String, to newName: String) {
        guard let delegate = delegate else {
            return
        }

        delegate.renameLevel(with: oldName, to: newName)
    }
}
