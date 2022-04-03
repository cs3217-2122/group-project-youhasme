//
//  GameState.swift
//  YouHasMe
//

import Foundation

enum PlayableLevel {
    case level(Level)
    case levelLoadable(Loadable)
}

extension PlayableLevel {
    func getLevel() -> Level {
        switch self {
        case .level(let level):
            return level
        case .levelLoadable(let loadable):
            let levelStorage = LevelStorage()
            guard let level: Level = levelStorage.loadLevel(name: loadable.name) else {
                fatalError("should not be nil")
            }
            return level
        }
    }
}

extension PlayableLevel: Equatable {}

enum PlayableMetaLevel {
    case metaLevel(MetaLevel)
    case metaLevelLoadable(Loadable)
}

extension PlayableMetaLevel: Equatable {}

extension PlayableMetaLevel {
    func getMetaLevel() -> MetaLevel {
        switch self {
        case .metaLevel(let metaLevel):
            return metaLevel
        case .metaLevelLoadable(let loadable):
            let metaLevelStorage = MetaLevelStorage()
            guard let metaLevel: MetaLevel = metaLevelStorage.loadMetaLevel(name: loadable.name) else {
                fatalError("should not be nil")
            }
            return metaLevel
        }
    }
}

enum ScreenState {
    case selecting
    case selectingMeta
    case playing(playableLevel: PlayableLevel)
    case playingMeta(playableMetaLevel: PlayableMetaLevel)
    case designing(playableLevel: PlayableLevel? = nil)
    case designingMeta(metaLevelLoadable: Loadable? = nil)
    case mainmenu
    case roomSelection
    case onlineMetaLevelSelection
}

extension ScreenState: Equatable {}

class GameState: ObservableObject {
    var state: ScreenState {
        get {
            guard let state = stateStack.last else {
                globalLogger.info("State stack is empty!")
                stateStack.append(.mainmenu)
                return .mainmenu
            }
            return state
        }
        set {
            stateStack.removeAll()
            stateStack.append(newValue)
        }
    }
    @Published var stateStack: [ScreenState] = []
    init() {
        stateStack.append(.mainmenu)
    }
    
    func append(state: ScreenState) {
        stateStack.append(state)
    }
}

// MARK: View model factories
extension GameState {
    func getLevelPlayViewModel() -> LevelDesignerViewModel {
        guard case let .playing(playableLevel: playableLevel) = state else {
            fatalError("Unexpected state")
        }

        let viewModel = LevelDesignerViewModel(playableLevel: playableLevel)
        // TODO: Move this elsewhere; bad to place it here
        // Even better: Make a specialized LevelPlayViewModel instead
        viewModel.currLevelLayer = RuleEngine().applyRules(to: viewModel.currLevelLayer)
        return viewModel
    }

    func getLevelDesignerViewModel() -> LevelDesignerViewModel {
        guard case let .designing(playableLevel: playableLevel) = state,
              let playableLevel = playableLevel else {
                  return LevelDesignerViewModel()
              }

        return LevelDesignerViewModel(playableLevel: playableLevel)
    }

    func getMetaLevelDesignerViewModel() -> MetaLevelDesignerViewModel {
        guard case let .designingMeta(metaLevelLoadable: metaLevelLoadable) = state,
            let metaLevelLoadable = metaLevelLoadable else {
            return MetaLevelDesignerViewModel()
        }
        print("metalevelloadable: \(metaLevelLoadable.name) \(metaLevelLoadable.url)")
        return MetaLevelDesignerViewModel(metaLevelLoadable: metaLevelLoadable)
    }

    func getMetaLevelPlayViewModel() -> MetaLevelPlayViewModel {
        guard case let .playingMeta(playableMetaLevel: playableMetaLevel) = state else {
            fatalError("Unexpected state")
        }

        return MetaLevelPlayViewModel(playableMetaLevel: playableMetaLevel)
    }

    func getMetaLevelSelectViewModel() -> MetaLevelSelectViewModel {
        MetaLevelSelectViewModel()
    }
    
    func getRoomListViewModel() -> RoomListViewModel {
        RoomListViewModel()
    }
    
    func getUploadedMetaLevelViewModel() -> UploadedMetaLevelSelectionViewModel {
        UploadedMetaLevelSelectionViewModel()
    }
}
