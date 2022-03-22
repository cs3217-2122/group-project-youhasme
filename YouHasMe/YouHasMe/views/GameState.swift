//
//  GameState.swift
//  YouHasMe
//

import Foundation

enum ScreenState {
    case selecting
    case playing
    case designing
    case mainmenu
}

class GameState: ObservableObject {
    @Published var state: ScreenState

    init() {
        state = .mainmenu
    }
}
