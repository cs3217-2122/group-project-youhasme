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
    let db = Firestore.firestore()
    @Published var levelRoom: LevelRoom?
    @Published var levelMoves: [LevelMove] = []

    init(roomId: String, dungeonRoomId: String, point: Point) {
        self.roomId = roomId
        self.dungeonRoomId = dungeonRoomId
        self.point = point
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
                        try? document.data(as: LevelMove.self)
                    }
                }
            }
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

    func updatePosition(pos: Point) {
        return
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
    
    @Published var dungeon: Dungeon
    @Published var playerNumAssignment: [String: Int] = [:]
    @Published var level: Level?
    @Published var moves: [LevelMove] = []
    @Published var playerPos: Point = Point.zero
//    @Published var currLevelLayer: LevelLayer?
    
//    var gameEngine: GameEngine {
//        didSet {
//            setupBindingsWithGameEngine()
//        }
//    }
    
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
    
    func setupBindingsWithGameEngine(gameEngine: GameEngine) {
        gameEngine.gameEventPublisher.sink { [weak self] gameEvent in
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

//        achievementsViewModel.resetSubscriptions()
//        achievementsViewModel.setSubscriptionsFor(gameEngine.gameEventPublisher)
    }
    
    func handleWin() {
        
    }
    
    func handleMoveAcrossLevel() {
        
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
                guard let persistableLevel = levelRoom?.persistableLeveL else {
                    return
                }
                
                let level = Level.fromPersistable(persistableLevel)
                level.winCount = levelRoom?.winCount ?? 0
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
        var gameEngine = GameEngine(levelLayer: levelLayer)
        for move in self.moves {
            if let playerNum = playerNumAssignment[move.playerId] {
                gameEngine.apply(action: Action(playerNum: playerNum, actionType: move.move))
                setupBindingsWithGameEngine(gameEngine: gameEngine)
            }
        }
        
        level.layer = gameEngine.currentGame.levelLayer
    }
}

extension MultiplayerPlayViewModel {
    func getTileViewModel(at viewOffset: Vector) -> EntityViewModel {
        let worldPosition = getWorldPosition(at: viewOffset)
        var tile: Tile? = nil
        var status = LevelStatus.inactiveAndIncomplete
        
        if let level = self.level {
            let worldPosition = getWorldPosition(at: viewOffset)
            let positionWithinLevel = dungeon.worldToPositionWithinLevel(worldPosition)
            tile = level.getTileAt(point: positionWithinLevel)
            status = LevelStatus.active
        }
        
        return EntityViewModel(
            tile: tile,
            worldPosition: worldPosition,
            status: status
        )
    }
}
