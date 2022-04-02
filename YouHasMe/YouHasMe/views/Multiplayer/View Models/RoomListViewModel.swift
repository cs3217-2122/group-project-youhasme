//
//  RoomListViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import Combine

class RoomListViewModel: ObservableObject {
    @Published var rooms: [OpenWorldRoom] = []
    var storage = FirebaseOpenWorldRoomStorage()
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        storage.$rooms
            .assign(to: \.rooms, on: self)
            .store(in: &cancellables)
    }
}
