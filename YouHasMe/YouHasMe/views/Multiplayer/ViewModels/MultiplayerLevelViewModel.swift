//
//  MultiplayerLevelViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 5/4/22.
//

import Foundation
import Combine
import Firebase

class LevelRoomListener: ObservableObject {
    var roomId: String
    @Published var levelRoom: LevelRoom?
    @Published var moves: [LevelMove] = []
    @Published var playerNum: Int?
    let db = Firestore.firestore()

    init(roomId: String) {
        self.roomId = roomId
    }

    func loadRoom() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }
        db.collection(FirebaseLevelRoomStorage.collectionPath).document(roomId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Couldn't load level room \(error.localizedDescription)")
                }

                if let querySnapshot = querySnapshot {
                    self.levelRoom = try? querySnapshot.data(as: LevelRoom.self)
                    if let levelRoom = self.levelRoom {
                        self.playerNum = levelRoom.playerNumAssignment[currentUserId]
                    }
                }
            }
    }

    func deleteRoom() {
        let roomRef = db.collection(FirebaseLevelRoomStorage.collectionPath).document(roomId)
        roomRef.delete()
        roomRef.collection("moves")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error retrieving moves: \(error.localizedDescription)")
                }

                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        document.reference.delete()
                    }
                }
            }
    }

    func sendAction(action: UpdateAction) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let move = LevelMove(player: currentUserId, move: action)
        let moveRef = db.collection(FirebaseLevelRoomStorage.collectionPath)
            .document(roomId).collection("moves").document()
        try? moveRef.setData(from: move)
    }

    func loadMoves() {
        db.collection(FirebaseLevelRoomStorage.collectionPath).document(roomId)
            .collection("moves")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting moves: \(error.localizedDescription)")
                }

                if let querySnapshot = querySnapshot {
                    self.moves = querySnapshot.documents.compactMap { document in
                        try? document.data(as: LevelMove.self)
                    }
                }
            }
    }

}

class MultiplayerLevelViewModel: ObservableObject {
    @Published var levelRoom: LevelRoom?
//    @Published var moves: [LevelMove] = []
    @Published var playerNum: Int?
//    @Published var localMoves: [UpdateAction] = []
    @Published var currLevelLayer: LevelLayer?
    @Published var showingWinAlert = false
    @Published var showingLoopAlert = false

    let currLevelLayerIndex = 0
    let listener: LevelRoomListener

    private var cancellables = Set<AnyCancellable>()

    var players: [String] {
        levelRoom?.playerIds ?? []
    }

//    var currLevelLayer: LevelLayer? {
//        get {
//            guard let levelRoom = self.levelRoom else {
//                return nil
//            }
//
//            guard let playerNum = self.playerNum else {
//                return nil
//            }
//
//            let initialLevelLayer = levelRoom.persistedLevel.layers.getAtIndex(currLevelLayerIndex)!
//            var gameEngine = GameEngine(levelLayer: initialLevelLayer)
//            for move in localMoves {
//                gameEngine.apply(action: Move(playerNum: playerNum, updateAction: move))
//            }
//            return gameEngine.currentGame.levelLayer
//        }
//    }

    init(roomId: String) {
        self.listener = LevelRoomListener(roomId: roomId)
        listener.loadRoom()
        listener.loadMoves()
        listener.$levelRoom
            .assign(to: \.levelRoom, on: self)
            .store(in: &cancellables)
        listener.$moves
            .sink { [weak self] moves in
                guard let self = self else {
                    return
                }
                if let levelRoom = self.levelRoom {
                    let levelLayer = levelRoom.persistedLevel.layers.getAtIndex(self.currLevelLayerIndex)!
                    var gameEngine = GameEngine(levelLayer: levelLayer)
                    for move in moves {
                        if let playerNum = levelRoom.playerNumAssignment[move.player] {
                            gameEngine.apply(action: Move(playerNum: playerNum, updateAction: move.move))
                        }
                    }
                    self.currLevelLayer = gameEngine.currentGame.levelLayer
                    self.showingWinAlert = gameEngine.currentGame.gameStatus == .win
                    self.showingLoopAlert = gameEngine.status == .infiniteLoop
                }

            }
            .store(in: &cancellables)
        listener.$playerNum
            .assign(to: \.playerNum, on: self)
            .store(in: &cancellables)
    }

    func sendAction(action: UpdateAction) {
//        localMoves.append(action)
        listener.sendAction(action: action)
    }

    func getWidth() -> Int {
        currLevelLayer?.dimensions.width ?? 0
    }

    func getHeight() -> Int {
        currLevelLayer?.dimensions.height ?? 0
    }

    func getEntityTypeAtPos(point: Point) -> EntityType? {
        guard let currLevelLayer = currLevelLayer else {
            return nil
        }
        let tile = currLevelLayer.getTileAt(x: point.x, y: point.y)
        if tile.entities.isEmpty {
            return nil
        } else {
            return tile.entities[0].entityType
        }
    }

    func deleteRoom() {
        listener.deleteRoom()
    }

}

extension MultiplayerLevelViewModel {
    func getTileViewModel(for entityType: EntityType) -> EntityViewModel {
        EntityViewModel(entityType: entityType)
    }

    func getTileViewModel(at point: Point) -> EntityViewModel {
        EntityViewModel(entityType: getEntityTypeAtPos(point: point))
    }
}
