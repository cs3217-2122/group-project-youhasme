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

class LevelRoomListener: ObservableObject {
    var roomId: String
    var dungeonRoomId: String
    var point: Point
    var roomHandle: ListenerRegistration?
    var moveHandle: ListenerRegistration?
    var storage = MultiplayerRoomStorage()
    let db = Firestore.firestore()
    @Published var levelRoom: LevelRoom?
    @Published var levelMoves: [LevelMove] = []
    
    init(roomId: String, dungeonRoomId: String, point: Point) {
        self.roomId = roomId
        self.dungeonRoomId = dungeonRoomId
        self.point = point
        storage.createLevelRoomIfNotExists(roomId: roomId, dungeonRoomId: dungeonRoomId, levelId: point.dataString)
    }
    
    func subscribe() {
        self.roomHandle = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(MultiplayerRoomStorage.dungeonCollectionPath).document(dungeonRoomId)
            .collection(MultiplayerRoomStorage.levelCollectionPath).document(point.dataString)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Couldnt observe level room \(error.localizedDescription)")
                }
                if let querySnapshot = querySnapshot {
                    self.levelRoom = try? querySnapshot.data(as: LevelRoom.self)
                }
            }

        self.moveHandle = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(MultiplayerRoomStorage.dungeonCollectionPath).document(dungeonRoomId)
            .collection(MultiplayerRoomStorage.levelCollectionPath).document(point.dataString)
            .collection("moves")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting moves: \(error.localizedDescription)")
                }

                if let querySnapshot = querySnapshot {
                    self.levelMoves = querySnapshot.documents.compactMap { document in
                        return try? document.data(as: LevelMove.self)
//                        if document.metadata.hasPendingWrites {
//                            return nil
//                        } else {
//                            return try? document.data(as: LevelMove.self)
//                        }
                    }
                }
            }
    }
    
    func incrementWinCount() {
        guard var levelRoomCopy = self.levelRoom else {
            return
        }
        
        levelRoomCopy.winCount += 1
        do {
            try storage.updateLevelRoom(roomId: self.roomId, dungeonRoomId: self.dungeonRoomId, levelRoom: levelRoomCopy)
        } catch {
            print("couldnt update win count")
        }
        
    }
    
    func sendAction(actionType: ActionType) {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                return
            }

            let move = LevelMove(playerId: currentUserId, move: actionType)
            let moveRef = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(MultiplayerRoomStorage.dungeonCollectionPath).document(dungeonRoomId)
            .collection(MultiplayerRoomStorage.levelCollectionPath).document(point.dataString)
            .collection("moves").document()
            try? moveRef.setData(from: move)
    }

    func unsubscribe() {
        self.roomHandle?.remove()
        self.moveHandle?.remove()
    }
}

class DungeonRoomListener: ObservableObject {
    var roomId: String
    var dungeonRoomId: String
    var handle: ListenerRegistration?
    let db = Firestore.firestore()
    let storage = MultiplayerRoomStorage()
    @Published var dungeonRoom: DungeonRoom?
    @Published var playerPos: Point = Point.zero
    @Published var playerNumAssignment: [String: Int] = [:]

    init(roomId: String, dungeonRoomId: String) {
        self.roomId = roomId
        self.dungeonRoomId = dungeonRoomId

    }

    func subscribe() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        self.handle = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .collection(MultiplayerRoomStorage.dungeonCollectionPath).document(dungeonRoomId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Couldnt observe dungeon room \(error.localizedDescription)")
                }
                if let querySnapshot = querySnapshot {
                    self.dungeonRoom = try? querySnapshot.data(as: DungeonRoom.self)
                    self.playerPos = self.dungeonRoom?.playerLocations[currentUserId] ?? Point.zero
                    self.playerNumAssignment = self.dungeonRoom?.players ?? [:]
                }

            }
    }

    func updatePosition(pos: Point, playerNum: Int) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        guard var dungeonRoomCopy = self.dungeonRoom else {
            return
        }
        
        if playerNum == 0 || playerNum == self.playerNumAssignment[currentUserId] {
            dungeonRoomCopy.playerLocations[currentUserId] = pos
            do {
                try storage.updateDungeonRoom(dungeonRoom: dungeonRoomCopy, roomId: self.roomId)
            } catch {
                print("Unable to update position")
            }
        }
    }

    func unsubscribe() {
        self.handle?.remove()
    }
}

class MultiplayerPlayViewModel: AbstractGridViewModel, IntegerViewTranslatable {
    var roomId: String
    var dungeonRoomId: String
    var dungeonRoomListener: DungeonRoomListener?
    var levelRoomListener: LevelRoomListener?
    var lastAction: ActionType = .tick

    @Published var dungeon: Dungeon
    @Published var playerNumAssignment: [String: Int] = [:]
    @Published var level: Level?
    @Published var moves: [LevelMove] = []
    @Published var playerPos: Point = Point.zero
    @Published var levelLayer: LevelLayer?
    @Published var showingWinAlert = false
    @Published var showingLoopAlert = false
    var isReplaying = false
//    @Published var currLevelLayer: LevelLayer?

//    var gameEngine: GameEngine {
//        didSet {
//            setupBindingsWithGameEngine()
//        }
//    }

    @Published var selectedTile: Tile?
    @Published var state: PlayViewState = .normalPlay
    
    var contextualData: [ContextualMenuData] {
        guard let entities = selectedTile?.entities else {
            return []
        }

        let data = Array(Set(entities.compactMap { ContextualMenuData(entityType: $0.entityType) })).sorted()
        data.forEach { $0.delegate = self }
        return data
    }
    
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
            print("GAME EVENT: \(gameEvent.type)")
            switch gameEvent.type {
            case .movingAcrossLevel(let playerNum):
                self.handleMoveAcrossLevel(playerNum: playerNum)
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
        let newPlayerLevelPosition = playerPos.translate(by: lastAction.getMovementAsVector())
        guard dungeon.dimensions.isWithinBounds(newPlayerLevelPosition) else {
            return
        }
        dungeonRoomListener?.updatePosition(pos: newPlayerLevelPosition, playerNum: playerNum)
        lastAction = .tick
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
    }

    func setUpLevelRoomListener(pos: Point) {
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
                self.applyMoves()
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
        isReplaying = true
        
        for (index, move) in self.moves.enumerated() {
            
            if index == self.moves.count - 1 {
                print("LAST MOVE")
                setupBindingsWithGameEngine(gameEngine: gameEngine)
            }
            if let playerNum = playerNumAssignment[move.playerId] {
                gameEngine.apply(action: Action(playerNum: playerNum, actionType: move.move))
            }
        }

        self.levelLayer = gameEngine.currentGame.levelLayer
        if gameEngine.currentGame.gameStatus == .win {
            self.handleWin()
            self.showingWinAlert = gameEngine.currentGame.gameStatus == .win
        }
        self.showingLoopAlert = gameEngine.status == .infiniteLoop
    }
}

extension MultiplayerPlayViewModel {
    func getTileViewModel(at viewOffset: Vector) -> EntityViewModel {
        let worldPosition = getWorldPosition(at: viewOffset)
        var tile: Tile? = nil
        var status = LevelStatus.inactiveAndIncomplete

        if let levelLayer = self.levelLayer {
//            print(level)
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

extension MultiplayerPlayViewModel: ContextualMenuDelegate {
    func closeOverlay() {
        state = .normalPlay
    }

    func showMessages() {
        state = .messages
    }
}
