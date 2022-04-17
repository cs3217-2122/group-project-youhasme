//
//  MultiplayerWaitRoomViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase
import Combine

class MultiplayerRoomListener: ObservableObject {
    var roomStorage = MultiplayerRoomStorage()
    let db = Firestore.firestore()
    var handle: ListenerRegistration?
    @Published var multiplayerRoom: MultiplayerRoom?
    @Published var playerStatus: PlayerStatus = .waiting
    @Published var isHost = false
    @Published var joinCode = ""

    func subscribe(roomId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("should be logged in")
        }

        self.handle = db.collection(MultiplayerRoomStorage.collectionPath).document(roomId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Couldnt listen to room \(error.localizedDescription)")
                }
                if let querySnapshot = querySnapshot {
                    self.multiplayerRoom = try? querySnapshot.data(as: MultiplayerRoom.self)
                    self.playerStatus = self.multiplayerRoom?.players[currentUserId]?.status ?? .waiting
                    self.isHost = self.multiplayerRoom?.creatorId == currentUserId
                    self.joinCode = self.multiplayerRoom?.joinCode ?? ""
                }
            }
    }

    func unsubscribe() {
        handle?.remove()
    }

    func updateSelectedDungeon(dungeon: OnlineDungeon) {
        guard var roomCopy = multiplayerRoom else {
            return
        }
        roomCopy.dungeon = dungeon
        roomCopy.uploadedDungeonId = dungeon.id
        do {
            try roomStorage.updateRoom(room: roomCopy)
        } catch {
            print("Coudn't update room")
        }
    }

    func createDungeonRoom() {
        guard let room = multiplayerRoom else {
            return
        }
        do {
            try roomStorage.createDungeonRoom(room: room)
        } catch {
            print("Couldn't create dungeon room")
        }

    }
}

class MultiplayerRoomViewModel: ObservableObject {
    var roomlistener = MultiplayerRoomListener()
    var dungeonListListener = OnlineDungeonListListener()
    @Published var isHost = false
    @Published var playerStatus: PlayerStatus = .waiting
    @Published var players: [Player] = []
    @Published var selectedDungeon: OnlineDungeon? = nil
    @Published var joinCode: String = ""

    private var cancellables = Set<AnyCancellable>()

    init(roomId: String) {
        roomlistener.subscribe(roomId: roomId)
        roomlistener.$multiplayerRoom
            .sink { [weak self] room in
                guard let self = self else {
                    return
                }
                guard let room = room else {
                    return
                }
                self.selectedDungeon = room.dungeon
                self.players = Array(room.players.values)
            }.store(in: &cancellables)

        roomlistener.$playerStatus
            .sink { [weak self] status in
                guard let self = self else {
                    return
                }
                self.playerStatus = status
            }.store(in: &cancellables)

        roomlistener.$isHost
            .sink { [weak self] isHostStatus in
                guard let self = self else {
                    return
                }
                self.isHost = isHostStatus
            }.store(in: &cancellables)
        
        roomlistener.$joinCode
            .sink { [weak self] code in
                guard let self = self else {
                    return
                }
                self.joinCode = code
            }.store(in: &cancellables)
    }

    deinit {
        roomlistener.unsubscribe()
    }

    func selectDungeon(onlineDungeon: OnlineDungeon) {
        roomlistener.updateSelectedDungeon(dungeon: onlineDungeon)
    }

    func startGame() {
        roomlistener.createDungeonRoom()
    }
}
