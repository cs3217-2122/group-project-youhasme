//
//  MultiplayerWaitRoomViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase
import Combine

class MultiplayerRoomViewModel: ObservableObject {
    var roomlistener = MultiplayerRoomListener()
    var dungeonListListener = OnlineDungeonListListener()
    @Published var isHost = false
    @Published var playerStatus: PlayerStatus = .waiting
    @Published var players: [Player] = []
    @Published var selectedDungeon: OnlineDungeon?
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
