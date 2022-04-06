//
//  DungeonPlayViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation
import CoreGraphics
import Combine

protocol ContextualMenuDelegate: AnyObject {
    func showMessages()
}

class ContextualMenuData {
    weak var delegate: ContextualMenuDelegate?
    let id: Int
    let description: String
    var action: () -> Void = {}

    init?(entityType: EntityType) {
        nil // TODO
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
}

class PlayViewModel: AbstractGridViewModel, DungeonManipulableViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    var viewableDimensions = Dungeon.defaultLevelDimensions
    @Published var hasWon = false
    @Published var isLoopingInfinitely = false
    var dungeon: Dungeon
    @Published var state: MetaLevelPlayViewState = .normal
    var gameEngine: GameEngine

    var contextualData: [ContextualMenuData] {
        guard let entities = selectedTile?.entities else {
            return []
        }

        let data = Array(Set(entities.compactMap { ContextualMenuData(entityType: $0.entityType) })).sorted()
        data.forEach { $0.delegate = self }
        return data
    }

    @Published var viewPosition: Point
    var cumulativeTranslation: CGVector = .zero {
        didSet {
            applyCumulativeTranslationToViewPosition()
        }
    }

    @Published var selectedTile: Tile?

    convenience init(playableDungeon: PlayableDungeon) {
        self.init(dungeon: playableDungeon.getDungeon())
    }

    init(dungeon: Dungeon) {
        self.dungeon = dungeon
        viewPosition = dungeon.entryWorldPosition
        let playerPosition = dungeon.getPlayerPosition()
        guard let level = dungeon.getLevel(at: playerPosition, loadNeighbors: false) else {
            fatalError("should not be nil")
        }
        gameEngine = GameEngine(levelLayer: level.layer)
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

    func playerMove(updateAction: UpdateType) {
        gameEngine.apply(action: updateAction)
        hasWon = gameEngine.currentGame.gameStatus == .win
        isLoopingInfinitely = gameEngine.status == .infiniteLoop
        dungeon.setLevelLayer(gameEngine.currentGame.levelLayer)
    }
}

extension PlayViewModel: ContextualMenuDelegate {
    func closeOverlay() {
        state = .normal
    }

    func showMessages() {
        state = .messages
    }
}

extension PlayViewModel: EntityViewModelExaminableDelegate {
    func examineTile(at worldPosition: Point) {
        selectedTile = dungeon.getTile(at: worldPosition, loadNeighboringLevels: false)
    }
}

extension PlayViewModel {
    func getTileViewModel(at viewOffset: Vector) -> EntityViewModel {
        let entityViewModel = EntityViewModel(
            tile: getTile(at: viewOffset, loadNeighboringChunks: true),
            worldPosition: getWorldPosition(at: viewOffset)
        )
        entityViewModel.examinableDelegate = self
        return entityViewModel
    }

    func getMessagesViewModel() -> MessagesViewModel {
        guard let tile = selectedTile else {
            fatalError("should not be nil")
        }

        return MessagesViewModel()
    }
}
