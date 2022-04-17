//
//  DungeonPlayViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation
import CoreGraphics
import Combine

enum PlayViewState {
    case disabled
    case normalPlay
}

class PlayViewModel: AbstractGridViewModel, DungeonManipulableViewModel {
    var baseViewOffset: Vector {
        let dx = max((viewableDimensions.width - levelDimensions.width) / 2, 0)
        let dy = max((viewableDimensions.height - levelDimensions.height) / 2, 0)
        return Vector(dx: -dx, dy: -dy)
    }

    @Published var gridDisplayMode: GridDisplayMode = .scaleToFitCellSize(
        cellSize: ViewConstants.gridCellDimensions
    )
    var displayModeOptions: [GridDisplayMode] {
        [
            .scaleToFitCellSize(cellSize: ViewConstants.gridCellDimensions),
            .fixedDimensionsInCells(dimensions: dungeon.levelDimensions)
        ]
    }

    private var subscriptions: Set<AnyCancellable> = []
    private var gameEngineSubscription: AnyCancellable?
    var viewableDimensions = Dungeon.defaultLevelDimensions
    var levelDimensions: Rectangle {
        dungeon.levelDimensions
    }
    @Published var hasWon = false
    @Published var isLoopingInfinitely = false
    var dungeon: Dungeon
    var currentLevelName: String {
        dungeon.getActiveLevel().name
    }
    @Published var state: PlayViewState = .normalPlay
    var gameEngine: GameEngine {
        didSet {
            setupBindingsWithGameEngine()
        }
    }

    var achievementsViewModel: AchievementsViewModel
    var notificationsViewModel: GameNotificationsViewModel

    @Published var viewPosition: Point
    var cumulativeTranslation: CGVector = .zero {
        didSet {
            applyCumulativeTranslationToViewPosition()
        }
    }

    @Published var selectedTile: Tile?
    private var timer: Timer?
    private var timedOffset: Vector = .zero
    @Published var levelsUpdated = false
    private var mostRecentPlayerMove: UpdateType?
    private var playerMovementAcrossLevel: Vector?

    convenience init(playableDungeon: PlayableDungeon, achievementsViewModel: AchievementsViewModel,
                     gameNotificationsViewModel: GameNotificationsViewModel) {
        self.init(dungeon: playableDungeon.getDungeon(), achievementsViewModel: achievementsViewModel,
                  gameNotificationsViewModel: gameNotificationsViewModel)
    }

    init(dungeon: Dungeon, achievementsViewModel: AchievementsViewModel,
         gameNotificationsViewModel: GameNotificationsViewModel) {
        self.achievementsViewModel = achievementsViewModel
        self.dungeon = dungeon
        viewPosition = dungeon.entryWorldPosition
        let level = dungeon.getActiveLevel()
        gameEngine = GameEngine(levelLayer: level.layer, ruleEngineDelegate: dungeon)
        self.notificationsViewModel = gameNotificationsViewModel
        setupBindings()
        setupBindingsWithGameEngine()
        setupBindingForNotifications()
        achievementsViewModel.selectLevel(levelId: level.id)
    }

    func setupBindings() {
        dungeon.$loadedLevels.sink { [weak self] loadedLevels in
            guard let self = self else {
                return
            }
            self.subscriptions.removeAll()
            for (_, loadedLevel) in loadedLevels {
                loadedLevel.$layer.sink { _ in
                    self.levelsUpdated = true
                }.store(in: &self.subscriptions)
            }
        }
        .store(in: &subscriptions)

        $selectedTile.sink { [weak self] selectedTile in
            guard let self = self else {
                return
            }
            if selectedTile == nil {
                self.state = .normalPlay
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

    func setupBindingForNotifications() {
        notificationsViewModel.setSubscriptionsFor(achievementsViewModel.gameNotifPublisher)
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

    func translateViewSlowly(by offset: Vector) {
        timedOffset = offset
        state = .disabled
        timer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            let unit = self.timedOffset.getUnit()
            self.timedOffset = self.timedOffset.subtract(unit)
            self.translateView(by: CGVector(unit))
            if self.timedOffset == .zero {
                timer.invalidate()
                self.state = .normalPlay
            }
        }
    }

    private func handlePostGameEngineUpdate() {
        guard let playerMovementAcrossLevel = playerMovementAcrossLevel else {
            return
        }

        guard let movementVector = self.mostRecentPlayerMove?.getMovementAsVector() else {
            return
        }

        let isMoveSuccessful = dungeon.movePlayer(by: playerMovementAcrossLevel)
        self.playerMovementAcrossLevel = nil
        guard isMoveSuccessful else {
            return
        }

        let level = dungeon.getActiveLevel()
        achievementsViewModel.selectLevel(levelId: level.id)
        gameEngine = GameEngine(levelLayer: level.layer, ruleEngineDelegate: dungeon)

        let viewVector = CGVector(movementVector).scale(
            factorX: Double(self.dungeon.levelDimensions.width),
            factorY: Double(self.dungeon.levelDimensions.height)
        )
        translateViewSlowly(by: viewVector.toVector())
    }

    func playerUndo() {
        gameEngine.undo()
        dungeon.setLevelLayer(gameEngine.currentGame.levelLayer)
        objectWillChange.send()
    }
}

extension PlayViewModel {
    func getTileViewModel(at viewOffset: Vector) -> EntityViewModel {
        let tile = getTile(at: viewOffset, loadNeighboringChunks: true)
        let worldPosition = getWorldPosition(at: viewOffset)
        let levelStatus = dungeon.getLevelStatus(forLevelAt: worldPosition)
        let entityViewModel = EntityViewModel(
            tile: tile,
            worldPosition: worldPosition,
            status: levelStatus,
            conditionEvaluableDelegate: dungeon
        )
        return entityViewModel
    }

    func getActiveRulesViewModel() -> ActiveRulesViewModel {
        ActiveRulesViewModel(lastActiveRulesPublisher: gameEngine.lastActiveRulesPublisher)
    }
}
