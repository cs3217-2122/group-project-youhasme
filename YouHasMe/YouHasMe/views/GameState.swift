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
    case designingMeta(metaLevelURLData: URLListObject? = nil)
    case mainmenu
    case rooms
    case metaLevelMultiplayer
}

extension ScreenState: Equatable {}

class GameState: ObservableObject {
    @Published var state: ScreenState

    init() {
        state = .mainmenu
    }
}

// MARK: View model factories
extension GameState {
    func getLevelDesignerViewModel() -> LevelDesignerViewModel {
        LevelDesignerViewModel()
    }

    func getMetaLevelDesignerViewModel() -> MetaLevelDesignerViewModel {
        guard case let .designingMeta(metaLevelURLData: metaLevelURLData) = state,
            let metaLevelURLData = metaLevelURLData else {
            return MetaLevelDesignerViewModel()
        }

        return MetaLevelDesignerViewModel(metaLevelURLData: metaLevelURLData)
    }

    func getMetaLevelSelectViewModel() -> MetaLevelSelectViewModel {
        MetaLevelSelectViewModel()
    }
    
    func getRoomListViewModel() -> RoomListViewModel {
        RoomListViewModel()
    }
    
    func getMetaLevelMultiplayerViewModel() -> MetaLevelMultiplayerViewModel {
        MetaLevelMultiplayerViewModel()
    }
}
