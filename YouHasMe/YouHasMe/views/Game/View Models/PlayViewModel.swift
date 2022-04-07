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

enum PlayViewState {
    case normal
    case messages
}

class PlayViewModel: AbstractGridViewModel, DungeonManipulableViewModel {
    private var subscriptions: Set<AnyCancellable> = []
    private var gameEngineSubscription: AnyCancellable?
    var viewableDimensions = Dungeon.defaultLevelDimensions
    @Published var hasWon = false
    @Published var isLoopingInfinitely = false
    var dungeon: Dungeon
    var currentLevelName: String {
        dungeon.getActiveLevel().name
    }
    @Published var state: PlayViewState = .normal
    var gameEngine: GameEngine {
        didSet {
            setupBindingsWithGameEngine()
        }
    }

    var achievementsViewModel: AchievementsViewModel

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

    private var mostRecentPlayerMove: UpdateType?
    private var playerMovementAcrossLevel: Vector?

    convenience init(playableDungeon: PlayableDungeon, achievementsViewModel: AchievementsViewModel) {
        self.init(dungeon: playableDungeon.getDungeon(), achievementsViewModel: achievementsViewModel)
    }

    init(dungeon: Dungeon, achievementsViewModel: AchievementsViewModel) {
        self.achievementsViewModel = achievementsViewModel
        self.dungeon = dungeon
        viewPosition = dungeon.entryWorldPosition
        let level = dungeon.getActiveLevel()
        gameEngine = GameEngine(levelLayer: level.layer, ruleEngineDelegate: dungeon)
        setupBindings()
        setupBindingsWithGameEngine()
        achievementsViewModel.levelId = level.id.dataString
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

    func setupBindingsWithGameEngine() {
        gameEngineSubscription = gameEngine.gameEventPublisher.sink { [weak self] gameEvent in
            guard let self = self else {
                return
            }

            switch gameEvent.type {
            case .movingAcrossLevel:
                self.handleMoveAcrossLevel()
            case .win:
                self.handleWin()
            default:
                break
            }
        }
        achievementsViewModel.resetSubscriptions()
        achievementsViewModel.setSubscriptionsFor(gameEngine.gameEventPublisher)
    }

    private func handleMoveAcrossLevel() {
        guard let mostRecentPlayerMove = self.mostRecentPlayerMove else {
            return
        }
        self.playerMovementAcrossLevel = mostRecentPlayerMove.getMovementAsVector()
    }

    private func handleWin() {
        dungeon.winActiveLevel()
    }

    func playerMove(updateAction: UpdateType) {
        mostRecentPlayerMove = updateAction
        gameEngine.apply(action: updateAction)
        hasWon = gameEngine.currentGame.gameStatus == .win
        isLoopingInfinitely = gameEngine.status == .infiniteLoop
        dungeon.setLevelLayer(gameEngine.currentGame.levelLayer)

        handlePostGameEngineUpdate()
        mostRecentPlayerMove = nil
    }

    private func handlePostGameEngineUpdate() {
        guard let playerMovementAcrossLevel = playerMovementAcrossLevel else {
            return
        }

        guard let movementVector = self.mostRecentPlayerMove?.getMovementAsVector() else {
            return
        }

        dungeon.movePlayer(by: playerMovementAcrossLevel)
        self.playerMovementAcrossLevel = nil

        let level = dungeon.getActiveLevel()
        achievementsViewModel.levelId = level.id.dataString
        gameEngine = GameEngine(levelLayer: level.layer, ruleEngineDelegate: dungeon)

        let viewVector = CGVector(movementVector).scale(
            factorX: Double(self.dungeon.levelDimensions.width),
            factorY: Double(self.dungeon.levelDimensions.height)
        )
        translateView(by: viewVector)
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
