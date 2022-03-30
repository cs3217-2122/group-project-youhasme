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
    case designingMeta(metaLevelURLData: Loadable? = nil)
    case mainmenu
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
}
