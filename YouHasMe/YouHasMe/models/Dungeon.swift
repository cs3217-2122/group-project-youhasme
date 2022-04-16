import Foundation
import Combine

protocol DungeonViewableDelegate: AnyObject {
    func getViewableRegion() -> PositionedRectangle
}

enum LevelStatus {
    case active
    case inactiveAndComplete
    case inactiveAndIncomplete
}

class Dungeon {
    static let defaultLevelDimensions = Rectangle(width: 16, height: 16)
    static let defaultDimensions = Rectangle(width: 2, height: 2)
    static let loadableRadius: Int = 1
    static let defaultName: String = "Dungeon1"
    static let defaultEntryLevelPosition: Point = .zero
    weak var viewableDelegate: DungeonViewableDelegate?
    var levelGenerator: AnyChunkGeneratorDelegate
    var levelNeighborFinder = ImmediateNeighborhoodChunkNeighborFinder()
        .eraseToAnyNeighborFinder()
    /// Uniform dimensions of each level within a dungeon.
    let levelDimensions: Rectangle
    /// Dimensions of the dungeon in terms of levels.
    let dimensions: Rectangle
    var loadableChunkRadius: Int {
        Dungeon.loadableRadius
    }
    var dungeonStorage = DungeonStorage()
    var levelStorage: LevelStorage {
        guard let storage = try? dungeonStorage.getLevelStorage(for: name) else {
            fatalError("unexpected failure")
        }
        return storage
    }
    @Published private(set) var name: String

    let entryLevelPosition: Point
    let entryWorldPosition: Point = .zero
    @Published var levelNameToPositionMap: [String: Point]
    var playerLevelPosition: Point
    @Published var loadedLevels: [Point: Level] = [:]
    var totalWins: Int = 0
    private var subscriptions: Set<AnyCancellable> = []

    convenience init() {
        self.init(
            isNewDungeon: true,
            name: Dungeon.defaultName,
            dimensions: Dungeon.defaultDimensions,
            levelDimensions: Dungeon.defaultLevelDimensions,
            entryLevelPosition: Dungeon.defaultEntryLevelPosition,
            levelNameToPositionMap: [:]
        )
    }

    init(
        isNewDungeon: Bool,
        name: String,
        dimensions: Rectangle,
        levelDimensions: Rectangle,
        entryLevelPosition: Point,
        levelNameToPositionMap: [String: Point],
        levelGenerators: [IdentityGeneratorDecorator.Type] = []
    ) {
        self.name = name
        self.dimensions = dimensions
        self.levelDimensions = levelDimensions
        self.entryLevelPosition = entryLevelPosition
        self.levelNameToPositionMap = levelNameToPositionMap
        playerLevelPosition = entryLevelPosition
        self.levelGenerator = BaseGenerator().decorateWithAll(levelGenerators)
        if isNewDungeon {
            for x in 0..<dimensions.width {
                for y in 0..<dimensions.height {
                    createLevel(at: Point(x: x, y: y))
                }
            }
            do {
                try dungeonStorage.saveDungeon(self)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    var numberOfPlayers: Int {
        0 // TODO
    }

    func renameDungeon(to newName: String) {
        let oldName = name
        do {
            globalLogger.info("Attempting to rename from \(oldName) to \(newName)")
            try dungeonStorage.renameDungeon(from: oldName, to: newName)
            name = newName
            try dungeonStorage.saveDungeon(self)
        } catch {
            globalLogger.error("\(error.localizedDescription)")
        }
    }

    func renameLevel(with oldName: String, to newName: String) {
        guard oldName != newName else {
            return
        }

        guard let levelPosition = levelNameToPositionMap[oldName] else {
            globalLogger.error("level with name not found")
            return
        }

        guard levelNameToPositionMap[newName] == nil else {
            globalLogger.info("level name is already in use")
            return
        }

        guard let level = getLevel(levelPosition: levelPosition) else {
            fatalError("should not be nil")
        }

        assert(level.name == oldName)
        level.name = newName
        levelNameToPositionMap[newName] = levelPosition
        levelNameToPositionMap[oldName] = nil
        do {
            try saveLoadedLevels()
            try dungeonStorage.saveDungeon(self)
        } catch {
            fatalError("failed to save")
        }
    }

    func setLevelLayer(_ levelLayer: LevelLayer) {
        let level = getActiveLevel()
        level.layer = levelLayer
    }

    func movePlayer(by vector: Vector) {
        let newPlayerLevelPosition = playerLevelPosition.translate(by: vector)
        guard dimensions.isWithinBounds(newPlayerLevelPosition) else {
            return
        }
        playerLevelPosition = newPlayerLevelPosition
    }

    func getActiveLevel() -> Level {
        guard let level = getLevel(levelPosition: playerLevelPosition) else {
            fatalError("should not be nil")
        }
        return level
    }

    func winActiveLevel() {
        let level = getActiveLevel()
        level.winCount += 1
        totalWins += 1
    }
}

extension Dungeon: Identifiable {
    typealias ObjectIdentifier = String
    var id: ObjectIdentifier {
        name
    }
}

extension Dungeon {
    func worldToLevelPosition(_ worldPosition: Point) -> Point {
        Point(
            x: worldPosition.x.flooredDiv(levelDimensions.width),
            y: worldPosition.y.flooredDiv(levelDimensions.height)
        )
    }

    func worldToPositionWithinLevel(_ worldPosition: Point) -> Point {
        Point(
            x: worldPosition.x.modulo(levelDimensions.width),
            y: worldPosition.y.modulo(levelDimensions.height)
        )
    }

    func worldRegionToLevelRegion(_ worldRegion: PositionedRectangle) -> PositionedRectangle {
        let chunkTopLeft = worldToLevelPosition(worldRegion.topLeft)
        let chunkBottomRight = worldToLevelPosition(worldRegion.bottomRight)
        return PositionedRectangle(
            rectangle: Rectangle(
                width: chunkBottomRight.x - chunkTopLeft.x,
                height: chunkBottomRight.y - chunkTopLeft.y
            ),
            topLeft: chunkTopLeft
        )
    }

    func getLevel(at worldPosition: Point, loadNeighbors: Bool) -> Level? {
        guard let level = getLevel(levelPosition: worldToLevelPosition(worldPosition)) else {
            return nil
        }

        if loadNeighbors {
            level.neighborFinderDelegate = levelNeighborFinder

            let levelPosition = worldToLevelPosition(worldPosition)
            let neighbors = level.loadNeighbors(at: levelPosition)
            for (neighborPosition, neighboringLevel) in neighbors where
                loadedLevels[neighborPosition] == nil {
                loadedLevels[neighborPosition] = neighboringLevel
            }
        }

        return level
    }

    func createLevel(at levelPosition: Point) {
        let level = Level(
            id: levelPosition,
            name: levelPosition.dataString,
            dimensions: levelDimensions
        )
        level.locationalDelegate = self
        level.generatorDelegate = self.levelGenerator

        do {
            try levelStorage.saveLevel(level)
        } catch {
            fatalError("unexpected save failure")
        }

        levelNameToPositionMap[level.name] = levelPosition
        loadedLevels[levelPosition] = level
    }

    func getLevel(levelPosition: Point) -> Level? {
        if let foundChunk = loadedLevels[levelPosition] {
            return foundChunk
        }

        guard let loadedLevel: Level = levelStorage.loadLevel(levelPosition) else {
            return nil
        }

        globalLogger.info("Loaded level with position \(levelPosition)")
        loadedLevels[levelPosition] = loadedLevel
        return loadedLevel
    }

    func unloadLevels() {
        guard let delegate = viewableDelegate else {
            return
        }
        let viewableWorldRegion = delegate.getViewableRegion()
        let viewableChunkRegion = worldRegionToLevelRegion(viewableWorldRegion)
        let loadableChunkRegion = viewableChunkRegion.expandInAllDirections(by: loadableChunkRadius)
        // Unload all chunks that are very far away from the viewable region
        for (position, loadedLevel) in loadedLevels {
            guard !loadableChunkRegion.contains(point: position) else {
                continue
            }

            do {
                try levelStorage.saveLevel(loadedLevel)
            } catch {
                fatalError("unexpected failure")
            }
            loadedLevels[position] = nil
        }
    }

    func getLevelStatus(forLevelAt worldPosition: Point) -> LevelStatus {
        let levelPosition = worldToLevelPosition(worldPosition)
        if playerLevelPosition == levelPosition {
            return .active
        }

        guard let level = getLevel(levelPosition: levelPosition) else {
            return .inactiveAndIncomplete
        }

        if level.winCount > 0 {
            return .inactiveAndComplete
        } else {
            return .inactiveAndIncomplete
        }
    }

    func getTile(at worldPosition: Point, loadNeighboringLevels: Bool) -> Tile? {
        guard let level = getLevel(at: worldPosition, loadNeighbors: loadNeighboringLevels) else {
            return nil
        }
        let positionWithinLevel = worldToPositionWithinLevel(worldPosition)

        return level.getTileAt(point: positionWithinLevel)
    }

    func setTile(_ tile: Tile, at worldPosition: Point) {
        guard let level = getLevel(at: worldPosition, loadNeighbors: false) else {
            return
        }
        let positionWithinLevel = worldToPositionWithinLevel(worldPosition)
        level.setTile(tile, at: positionWithinLevel)
    }
}

extension Dungeon: Equatable {
    static func == (lhs: Dungeon, rhs: Dungeon) -> Bool {
        lhs === rhs
    }
}

// MARK: Persistence
extension Dungeon {
    func saveLoadedLevels() throws {
        for loadedLevel in loadedLevels.values {
            try levelStorage.saveLevel(loadedLevel)
        }
    }

    func toPersistable() -> PersistableDungeon {
        PersistableDungeon(
            name: name,
            dimensions: dimensions,
            levelDimensions: levelDimensions,
            entryLevelPosition: entryLevelPosition,
            levelNameToPositionMap: levelNameToPositionMap
        )
    }

    static func fromPersistable(_ persistableDungeon: PersistableDungeon) -> Dungeon {
        let dungeon = Dungeon(
            isNewDungeon: false,
            name: persistableDungeon.name,
            dimensions: persistableDungeon.dimensions,
            levelDimensions: persistableDungeon.levelDimensions,
            entryLevelPosition: persistableDungeon.entryLevelPosition,
            levelNameToPositionMap: persistableDungeon.levelNameToPositionMap
        )
        return dungeon
    }
}

enum DungeonKeyPathKeys: String, AbstractKeyPathIdentifierEnum {
    case totalWins = "Total Wins"
    case numberOfPlayers = "Number of dungeon players"
}

extension Dungeon: KeyPathExposable {

    static var exposedNumericKeyPathsMap: [DungeonKeyPathKeys: KeyPath<Dungeon, Int>] {
        [
            .totalWins: \.totalWins,
            .numberOfPlayers: \.numberOfPlayers
        ]
    }

    func evaluate(given keyPath: NamedKeyPath<DungeonKeyPathKeys, Dungeon, Int>) -> Int {
        self[keyPath: keyPath.keyPath]
    }
}

extension Dungeon: LevelLocationalDelegate {
    var extremities: Rectangle {
        dimensions
    }
}

extension Dungeon: RuleEngineDelegate {
    var dungeon: Dungeon {
        self
    }

    var dungeonName: String {
        name
    }

    func getLevel(by id: Point) -> Level? {
        getLevel(levelPosition: id)
    }

    func getLevelName(by id: Point) -> String? {
        getLevel(levelPosition: id)?.name
    }
}
