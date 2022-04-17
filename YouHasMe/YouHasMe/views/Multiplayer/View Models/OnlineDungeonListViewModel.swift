//
//  OnlineDungeonListViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import Foundation
import Firebase
import Combine

class OnlineDungeonListViewModel: ObservableObject {
    var listener = OnlineDungeonListListener()
    @Published var onlineDungeons: [OnlineDungeon] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        listener.subscribe()
        listener.$onlineDungeons
            .assign(to: \.onlineDungeons, on: self)
            .store(in: &cancellables)
    }

    deinit {
        listener.unsubscribe()
    }
}
