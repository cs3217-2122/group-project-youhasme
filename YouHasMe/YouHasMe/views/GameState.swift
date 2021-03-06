//
//  GameState.swift
//  YouHasMe
//

import Foundation

struct DungeonParams: Equatable {
    var name: String
    var dimensions: Rectangle
    var generators: [IdentityGeneratorDecorator.Type]
    static func == (lhs: DungeonParams, rhs: DungeonParams) -> Bool {
        lhs.name == rhs.name
    }
}

struct DungeonPlayParams: Equatable {
    var neighborFinder: AnyNeighborFinderDelegate<Point>
    static func == (lhs: DungeonPlayParams, rhs: DungeonPlayParams) -> Bool {
        lhs.neighborFinder === rhs.neighborFinder
    }
}

enum DesignableDungeon {
    case dungeonLoadable(Loadable)
    case newDungeon(DungeonParams)
}

extension DesignableDungeon {
    func getDungeon() -> Dungeon {
        switch self {
        case .dungeonLoadable(let loadable):
            let dungeonStorage = DungeonStorage()
            guard let dungeon: Dungeon = dungeonStorage.loadDungeon(name: loadable.name) else {
                fatalError("should not be nil")
            }
            return dungeon
        case .newDungeon(let params):
            let name = params.name
            let dimensions = params.dimensions
            let generators = params.generators
            return Dungeon(
                isNewDungeon: true,
                name: name,
                dimensions: dimensions,
                levelDimensions: Dungeon.defaultLevelDimensions,
                entryLevelPosition: Dungeon.defaultEntryLevelPosition,
                levelNameToPositionMap: [:],
                levelGenerators: generators
            )
        }
    }
}

extension DesignableDungeon: Equatable {}

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
    case multiplayerEntry
    case multiplayer(roomId: String)
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
    func getDimensionSelectViewModel() -> DimensionSelectViewModel {
        DimensionSelectViewModel()
    }

    func getDesignerViewModel() -> DesignerViewModel {
        let achievementsViewModel = getAchievementsViewModel()
        let gameNotificationsViewModel = getGameNotificationsViewModel()
        guard case let .designing(designableDungeon: designableDungeon) = state,
              let designableDungeon = designableDungeon else {
            return DesignerViewModel(achievementsViewModel: achievementsViewModel,
                                     gameNotificationsViewModel: gameNotificationsViewModel)
        }
        return DesignerViewModel(
            designableDungeon: designableDungeon,
            achievementsViewModel: achievementsViewModel,
            gameNotificationsViewModel: gameNotificationsViewModel
        )
    }

    func getPlayViewModel() -> PlayViewModel {
        let achievementsViewModel = getAchievementsViewModel()
        let gameNotificationsViewModel = getGameNotificationsViewModel()
        guard case let .playing(playableDungeon: playableDungeon) = state else {
            fatalError("Unexpected state")
        }

        return PlayViewModel(
            playableDungeon: playableDungeon,
            achievementsViewModel: achievementsViewModel,
            gameNotificationsViewModel: gameNotificationsViewModel
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

    func getGameNotificationsViewModel() -> GameNotificationsViewModel {
        GameNotificationsViewModel()
    }

    func getMultiplayerRoomViewModel() -> MultiplayerRoomViewModel {
        if case let .multiplayer(roomId: roomId) = state {
            return MultiplayerRoomViewModel(roomId: roomId)
        }
        fatalError("unexpected state")
    }
}
