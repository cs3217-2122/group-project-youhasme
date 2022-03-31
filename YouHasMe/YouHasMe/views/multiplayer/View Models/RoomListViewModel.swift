//
//  RoomListViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 31/3/22.
//

import Foundation
import Combine

class RoomListViewModel: ObservableObject {
    var roomStorage = FirebaseRoomStorage()
    
    @Published var rooms: [MetaLevelRoom] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        roomStorage.$rooms
            .assign(to: \.rooms, on: self)
            .store(in: &cancellables)
    }
    
    func joinRoom(code: String) {
        guard let intCode = Int(code) else {
            return
        }
        roomStorage.joinRoom(inputCode: intCode)
    }
}
