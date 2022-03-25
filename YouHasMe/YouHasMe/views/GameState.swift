//
//  GameState.swift
//  YouHasMe
//

import Foundation

enum ScreenState {
    case selecting
    case selectingMeta
    case playing
    case designing
    case designingMeta
    case mainmenu
}

class GameState: ObservableObject {
    @Published var state: ScreenState

    init() {
        state = .mainmenu
    }
}
