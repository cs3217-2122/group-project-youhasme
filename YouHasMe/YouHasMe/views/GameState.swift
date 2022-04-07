//
//  GameState.swift
//  YouHasMe
//

import Foundation

enum DesignableDungeon {
    case dungeonLoadable(Loadable)
    case newDungeonDimensions(Rectangle)
}

extension DesignableDungeon: Equatable {}

extension DesignableDungeon {
    func getDungeon() -> Dungeon {
        switch self {
        case .dungeonLoadable(let loadable):
            let dungeonStorage = DungeonStorage()
            guard let dungeon: Dungeon = dungeonStorage.loadDungeon(name: loadable.name) else {
                fatalError("should not be nil")
            }
            return dungeon
        case .newDungeonDimensions(let rectangle):
            return Dungeon(
                isNewDungeon: true,
                name: Dungeon.defaultName,
                dimensions: rectangle,
                levelDimensions: Dungeon.defaultLevelDimensions,
                entryLevelPosition: Dungeon.defaultEntryLevelPosition
            )
        }
    }
}

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
    case choosingDimensions
    case designing(designableDungeon: DesignableDungeon?)
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
        let achievementsViewModel = getAchievementsViewModel()
        guard case let .designing(designableDungeon: designableDungeon) = state,
              let designableDungeon = designableDungeon else {
            return DesignerViewModel(achievementsViewModel: achievementsViewModel)
        }
        return DesignerViewModel(
            designableDungeon: designableDungeon,
            achievementsViewModel: achievementsViewModel
        )
    }

    func getPlayViewModel() -> PlayViewModel {
        let achievementsViewModel = getAchievementsViewModel()
        guard case let .playing(playableDungeon: playableDungeon) = state else {
            fatalError("Unexpected state")
        }

        return PlayViewModel(
            playableDungeon: playableDungeon,
            achievementsViewModel: achievementsViewModel
        )
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
        } else if case let .designing(designableDungeon: designableDungeon) = state,
                  let designableDungeon = designableDungeon {
            dungeonId = designableDungeon.getDungeon().id
        }

        return AchievementsViewModel(dungeonId: dungeonId)
    }
}
