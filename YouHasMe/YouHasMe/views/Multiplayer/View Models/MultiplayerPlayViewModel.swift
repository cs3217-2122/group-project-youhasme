//
//  MultiplayerPlayViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase
import Combine
import SwiftUI

class MultiplayerPlayViewModel: AbstractGridViewModel, IntegerViewTranslatable {
    var roomId: String
    var dungeonRoomId: String
    var dungeonRoomListener: DungeonRoomListener?
    var levelRoomListener: LevelRoomListener?
    var lastAction: ActionType = .tick
    
    var dungeon: Dungeon
    var playerNumAssignment: [String: Int] = [:]
    @Published var level: Level?
    var moves: [LevelMove] = []
    @Published var playerPos: Point = Point.zero
    
    var moveAcrossLevel = false
    var moveAcrossLevelPlayer = 1

    @Published var levelLayer: LevelLayer?
    @Published var showingWinAlert = false
    @Published var showingLoopAlert = false

    @Published var selectedTile: Tile?
    @Published var state: PlayViewState = .normalPlay
    
    @Published var playerNum: Int?
    
    func setupSelectedTileBindings() {
        $selectedTile.sink { [weak self] selectedTile in
            guard let self = self else {
                return
            }
            if selectedTile == nil {
                self.state = .normalPlay
            }
        }.store(in: &cancellables)
    }

    var cumulativeTranslation: CGVector = .zero {
        didSet {
            applyCumulativeTranslationToViewPosition()
        }
    }

    @Published var viewPosition: Point = Point.zero

    var viewableDimensions = Dungeon.defaultLevelDimensions

    var levelDimensions: Rectangle {
        dungeon.levelDimensions
    }

    var baseViewOffset: Vector {
        let dx = max((viewableDimensions.width - levelDimensions.width) / 2, 0)
        let dy = max((viewableDimensions.height - levelDimensions.height) / 2, 0)
        return Vector(dx: -dx, dy: -dy)
    }

    @Published var gridDisplayMode: GridDisplayMode
    var displayModeOptions: [GridDisplayMode] {
        [
            .fixedDimensionsInCells(dimensions: dungeon.levelDimensions)
        ]
    }

    private var cancellables = Set<AnyCancellable>()

    init(roomId: String, dungeonRoomId: String) {
        self.roomId = roomId
        self.dungeonRoomId = dungeonRoomId
        let dungeon = Dungeon()
        self.dungeon = dungeon
        gridDisplayMode = .fixedDimensionsInCells(dimensions: dungeon.levelDimensions)
        self.setUpDungeonRoomListener()
    }
    
    private var gameEngineSubscription: AnyCancellable?

    func setupBindingsWithGameEngine(gameEngine: GameEngine) {
        gameEngineSubscription = gameEngine.gameEventPublisher.sink { [weak self] gameEvent in
            guard let self = self else {
                return
            }
//            print("GAME EVENT: \(gameEvent.type)")
            switch gameEvent.type {
            case .movingAcrossLevel(let playerNum):
                self.moveAcrossLevel = true
                self.moveAcrossLevelPlayer = playerNum
//                self.levelLayer = nil
//                self.handleMoveAcrossLevel(playerNum: playerNum)
//            case .win:
//                self.handleWin()
            default:
                break
            }
        }
//        achievementsViewModel.resetSubscriptions()
//        achievementsViewModel.setSubscriptionsFor(gameEngine.gameEventPublisher)
    }
    
    func sendAction(actionType: ActionType) {
        lastAction = actionType
        levelRoomListener?.sendAction(actionType: actionType)
    }
    
    func handleWin() {
        levelRoomListener?.incrementWinCount()
    }

    func handleMoveAcrossLevel(playerNum: Int) {
//        self.levelLayer = nil
        let newPlayerLevelPosition = playerPos.translate(by: lastAction.getMovementAsVector())
        guard dungeon.dimensions.isWithinBounds(newPlayerLevelPosition) else {
            return
        }
        lastAction = .tick
        self.moveAcrossLevel = false
        self.moveAcrossLevelPlayer = 1
        dungeonRoomListener?.updatePosition(pos: newPlayerLevelPosition, playerNum: playerNum)
    }

    func setUpDungeonRoomListener() {
        self.dungeonRoomListener = DungeonRoomListener(roomId: self.roomId, dungeonRoomId: self.dungeonRoomId)
        self.dungeonRoomListener?.subscribe()

        self.dungeonRoomListener?.$dungeonRoom
            .sink { [weak self] dungeonRoom in
                guard let self = self else {
                    return
                }

                guard let persistedDungeon = dungeonRoom?.dungeon.persistedDungeon else {
                    return
                }
                self.dungeon = Dungeon.fromPersistable(persistedDungeon)
            }.store(in: &cancellables)

        self.dungeonRoomListener?.$playerPos
            .sink { [weak self] pos in
                guard let self = self else {
                    return
                }
                self.playerPos = pos
                self.setUpLevelRoomListener(pos: pos)
            }.store(in: &cancellables)

        self.dungeonRoomListener?.$playerNumAssignment
            .sink { [weak self] playerNumAssignment in
                guard let self = self else {
                    return
                }
                self.playerNumAssignment = playerNumAssignment
            }.store(in: &cancellables)
        self.dungeonRoomListener?.$playerNum
            .sink { [weak self] playerNum in
                guard let self = self else {
                    return
                }
                self.playerNum = playerNum
            }.store(in: &cancellables)
    }

    func setUpLevelRoomListener(pos: Point) {
//        self.levelLayer = nil
        self.levelRoomListener?.unsubscribe()
        self.levelRoomListener = LevelRoomListener(roomId: self.roomId, dungeonRoomId: self.dungeonRoomId, point: pos)
        self.levelRoomListener?.subscribe()

        self.levelRoomListener?.$levelRoom
            .sink { [weak self] levelRoom in
                guard let self = self else {
                    return
                }
                guard let persistableLevel: PersistableLevel = levelRoom?.persistableLevel else {
                    return
                }

                let level = Level.fromPersistable(persistableLevel)
//                print("HERE")
//                print(level.name)
                level.winCount = levelRoom?.winCount ?? 0
                self.level = level
                if self.moves.isEmpty {
                    self.levelLayer = level.layer
                }
            }.store(in: &cancellables)

        self.levelRoomListener?.$levelMoves
            .sink { [weak self] moves in
                guard let self = self else {
                    return
                }
                self.moves = moves
                self.applyMoves()
            }.store(in: &cancellables)
    }

    func applyMoves() {
        guard let level = level else {
            return
        }
        let levelLayer = level.layer
        var gameEngine = GameEngine(levelLayer: levelLayer, ruleEngineDelegate: self)
        
        for (index, move) in self.moves.enumerated() {
            
            if index == self.moves.count - 1 {
                setupBindingsWithGameEngine(gameEngine: gameEngine)
            }
            if let playerNum = playerNumAssignment[move.playerId] {
                gameEngine.apply(action: Action(playerNum: playerNum, actionType: move.move))
            }
        }

        self.levelLayer = gameEngine.currentGame.levelLayer
        if gameEngine.currentGame.gameStatus == .win {
            if let lastMove = moves.last, let listener = dungeonRoomListener {
                if listener.isCurrentPlayer(playerId: lastMove.playerId) {
                    self.handleWin()
                }
            }
        }
        
        if moveAcrossLevel {
            self.handleMoveAcrossLevel(playerNum: moveAcrossLevelPlayer)
        }
        self.showingWinAlert = gameEngine.currentGame.gameStatus == .win
        self.showingLoopAlert = gameEngine.status == .infiniteLoop
    }
}

extension MultiplayerPlayViewModel {
    func getTileViewModel(at viewOffset: Vector) -> EntityViewModel {
        let worldPosition = getWorldPosition(at: viewOffset)
        var tile: Tile? = nil
        var status = LevelStatus.inactiveAndIncomplete

        if let levelLayer = self.levelLayer {
            let worldPosition = getWorldPosition(at: viewOffset)
            let positionWithinLevel = dungeon.worldToPositionWithinLevel(worldPosition)
            tile = levelLayer.getTileAt(point: positionWithinLevel)
            status = LevelStatus.active
        }

        return EntityViewModel(
            tile: tile,
            worldPosition: worldPosition,
            status: status,
            conditionEvaluableDelegate: self
        )
    }
}

extension MultiplayerPlayViewModel : RuleEngineDelegate {
    var dungeonName: String {
        self.dungeon.name
    }

    func getLevel(by id: Point) -> Level? {
        self.level
    }

    func getLevelName(by id: Point) -> String? {
        self.level?.name
    }
}
