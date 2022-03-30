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
        id = metaEntity.rawValue
        switch metaEntity {
        case .blocking, .nonBlocking, .space:
            return nil
        case .level:
            description = "Play Level"
            action = { [weak self] in
                self?.delegate?.showLevel()
            }
        case .travel:
            description = "Travel somewhere"
            action = { [weak self] in
                self?.delegate?.showTravel()
            }
        case .message:
            description = "Show Messages"
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

enum OverlayState {
    case off
    case messages
    case level
    case travel
}

class MetaLevelPlayViewModel: AbstractMetaLevelGridViewModel, MetaLevelManipulableViewModel {
    var viewableDimensions = Rectangle(
        width: ChunkNode.chunkDimensions,
        height: ChunkNode.chunkDimensions
    )

    var currMetaLevel: MetaLevel
    @Published var overlayState: OverlayState = .off

    var contextualData: [ContextualMenuData] {
        let playerPosition: Point = .zero // TODO

        guard let metaEntities = currMetaLevel.getTile(at: playerPosition)?.metaEntities else {
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

    convenience init() {
        self.init(currMetaLevel: MetaLevel())
    }

    convenience init(metaLevelURLData: URLListObject) {
        let metaLevelStorage = MetaLevelStorage()
        guard let currMetaLevel: MetaLevel = metaLevelStorage.loadMetaLevel(name: metaLevelURLData.name) else {
            fatalError("should not be nil")
        }

        self.init(currMetaLevel: currMetaLevel)
    }

    init(currMetaLevel: MetaLevel) {
        self.currMetaLevel = currMetaLevel
        viewPosition = currMetaLevel.entryWorldPosition
    }
}

extension MetaLevelPlayViewModel: ContextualMenuDelegate {
    func closeOverlay() {
        overlayState = .off
    }
    
    func showLevel() {
        overlayState = .level
    }

    func showTravel() {
        overlayState = .travel
    }

    func showMessages() {
        overlayState = .messages
    }
}

extension MetaLevelPlayViewModel {
    func getTileViewModel(at viewOffset: Vector) -> MetaEntityViewModel {
        let metaEntityViewModel = MetaEntityViewModel(
            tile: getTile(at: viewOffset),
            worldPosition: getWorldPosition(at: viewOffset)
        )
        return metaEntityViewModel
    }
    
    func getMessagesViewModel() -> MessagesViewModel {
        let playerPosition: Point = .zero // TODO

        guard let tile = currMetaLevel.getTile(at: playerPosition) else {
            fatalError("should not be nil")
        }
        
        return MessagesViewModel(tile: tile)
    }
}
