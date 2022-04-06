//
//  GameState.swift
//  YouHasMe
//

import Foundation

enum PlayableDungeon {
    case dungeon(Dungeon)
    case dungeonLoadable(Loadable)
}

extension PlayableDungeon: Equatable {}

extension PlayableDungeon {
    func getDungeon() -> Dungeon {
        switch self {
        case .dungeon(let dungeon):
            return dungeon
        case .dungeonLoadable(let loadable):
            let dungeonStorage = DungeonStorage()
            guard let dungeon: Dungeon = dungeonStorage.loadDungeon(name: loadable.name) else {
                fatalError("should not be nil")
            }
            return dungeon
        }
    }
}

enum ScreenState {
    case selecting
    case playing(playableDungeon: PlayableDungeon)
    case designing(loadable: Loadable? = nil)
    case mainmenu
    case achievements
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
}

// MARK: View model factories
extension GameState {
    func getDesignerViewModel() -> DesignerViewModel {
        guard case let .designing(loadable: loadable) = state,
            let loadable = loadable else {
            return DesignerViewModel()
        }
        return DesignerViewModel(dungeonLoadable: loadable)
    }

    func getPlayViewModel() -> PlayViewModel {
        guard case let .playing(playableDungeon: playableDungeon) = state else {
            fatalError("Unexpected state")
        }

        return PlayViewModel(playableDungeon: playableDungeon)
    }

    func getSelectViewModel() -> DungeonSelectViewModel {
        guard state == .selecting else {
            fatalError("unexpected state")
        }
        return DungeonSelectViewModel()
    }

    func getAchievementsViewModel() -> AchievementsViewModel {
        var dungeonId = ""
        if case let .playing(playableDungeon: playableDungeon) = state {
            dungeonId = playableDungeon.getDungeon().id
        } else if case let .designing(loadable: loadable) = state, let loadable = loadable {
            dungeonId = loadable.name
        }

        return AchievementsViewModel(levelId: dungeonId)
    }
}
