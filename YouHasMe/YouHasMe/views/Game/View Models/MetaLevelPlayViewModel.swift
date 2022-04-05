//
//  MetaLevelPlayViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation
import CoreGraphics
import Combine

protocol ContextualMenuDelegate: AnyObject {
    func showLevel()
    func showTravel()
    func showMessages()
}

class ContextualMenuData {
    weak var delegate: ContextualMenuDelegate?
    let id: Int
    let description: String
    var action: () -> Void = {}

    init?(metaEntity: MetaEntityType) {
        guard let index = metaEntity.getSelfWithDefaultValues().index else {
            return nil
        }
        id = index
        switch metaEntity {
        case .blocking, .nonBlocking, .grass:
            return nil
        case .level:
            description = "Levels"
            action = { [weak self] in
                self?.delegate?.showLevel()
            }
        case .travel:
            description = "Travel points"
            action = { [weak self] in
                self?.delegate?.showTravel()
            }
        case .message:
            description = "Messages"
            action = { [weak self] in
                self?.delegate?.showMessages()
            }
        }
    }
}

extension ContextualMenuData: Identifiable {}

extension ContextualMenuData: Hashable {
    static func == (lhs: ContextualMenuData, rhs: ContextualMenuData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ContextualMenuData: Comparable {
    static func < (lhs: ContextualMenuData, rhs: ContextualMenuData) -> Bool {
        lhs.id < rhs.id
    }
}

enum MetaLevelPlayViewState {
    case normal
    case messages
    case level
    case travel
}

class MetaLevelPlayViewModel: AbstractGridViewModel, DungeonManipulableViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    var viewableDimensions = Rectangle(
        width: ChunkNode.chunkDimensions,
        height: ChunkNode.chunkDimensions
    )

    var currMetaLevel: MetaLevel
    @Published var state: MetaLevelPlayViewState = .normal

    var contextualData: [ContextualMenuData] {
        guard let metaEntities = selectedTile?.metaEntities else {
            return []
        }

        let data = Array(Set(metaEntities.compactMap { ContextualMenuData(metaEntity: $0) })).sorted()
        data.forEach { $0.delegate = self }
        return data
    }

    @Published var viewPosition: Point
    var cumulativeTranslation: CGVector = .zero {
        didSet {
            applyCumulativeTranslationToViewPosition()
        }
    }

    @Published var selectedTile: MetaTile?

    convenience init(playableMetaLevel: PlayableMetaLevel) {
        self.init(currMetaLevel: playableMetaLevel.getMetaLevel())
    }

    init(currMetaLevel: MetaLevel) {
        self.currMetaLevel = currMetaLevel
        viewPosition = currMetaLevel.entryWorldPosition
        setupBindings()
    }

    func setupBindings() {
        $selectedTile.sink { [weak self] selectedTile in
            guard let self = self else {
                return
            }
            if selectedTile == nil {
                self.state = .normal
            }
        }.store(in: &subscriptions)
    }
}

extension MetaLevelPlayViewModel: ContextualMenuDelegate {
    func closeOverlay() {
        state = .normal
    }

    func showLevel() {
        state = .level
    }

    func showTravel() {
        state = .travel
    }

    func showMessages() {
        state = .messages
    }
}

extension MetaLevelPlayViewModel: MetaEntityViewModelExaminableDelegate {
    func examineTile(_ tile: MetaTile) {
        selectedTile = tile
    }
}

extension MetaLevelPlayViewModel {
    func getTileViewModel(at viewOffset: Vector) -> MetaEntityViewModel {
        let metaEntityViewModel = MetaEntityViewModel(
            tile: getTile(at: viewOffset, createChunkIfNotExists: false, loadNeighboringChunks: true),
            worldPosition: getWorldPosition(at: viewOffset)
        )
        metaEntityViewModel.examinableDelegate = self
        return metaEntityViewModel
    }

    func getMessagesViewModel() -> MessagesViewModel {
        guard let tile = selectedTile else {
            fatalError("should not be nil")
        }

        return MessagesViewModel(tile: tile)
    }

    func getMetaLevelInfoViewModel() -> MetaLevelInfoViewModel {
        guard let tile = selectedTile else {
            fatalError("should not be nil")
        }

        return MetaLevelInfoViewModel(tile: tile)
    }

    func getLevelInfoViewModel() -> LevelInfoViewModel {
        guard let tile = selectedTile else {
            fatalError("should not be nil")
        }

        return LevelInfoViewModel(tile: tile)
    }
}
