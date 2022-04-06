import Foundation
import Combine

protocol DungeonViewableDelegate: AnyObject {
    func getViewableRegion() -> PositionedRectangle
}

class Dungeon {
    static let defaultLevelDimensions = Rectangle(width: 16, height: 16)
    static let defaultDimensions = Rectangle(width: 2, height: 2)
    static let loadableRadius: Int = 1
    static let defaultName: String = "Dungeon1"
    weak var viewableDelegate: DungeonViewableDelegate?
    var levelGenerator = CompletelyEnclosedGenerator()
        .decorateWith(SnakeLikeConnectorGeneratorDecorator.self)
        .decorateWith(SnakeLikeConnectorLockGeneratorDecorator.self)
    var levelNeighborFinder = ImmediateNeighborhoodChunkNeighborFinder().eraseToAnyNeighborFinder()
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

    var entryChunkPosition: Point = .zero
    var entryWorldPosition: Point = .zero
    var levelNameToPositionMap: [String: Point] = [:]

    @Published var loadedLevels: [Point: Level] = [:]

    private var subscriptions: Set<AnyCancellable> = []

    convenience init() {
        self.init(
            isNewDungeon: true,
            name: Dungeon.defaultName,
            dimensions: Dungeon.defaultDimensions,
            levelDimensions: Dungeon.defaultLevelDimensions,
            entryChunkPosition: .zero
        )
    }

    init(
        isNewDungeon: Bool,
        name: String,
        dimensions: Rectangle,
        levelDimensions: Rectangle,
        entryChunkPosition: Point
    ) {
        self.name = name
        self.dimensions = dimensions
        self.levelDimensions = levelDimensions
        self.entryChunkPosition = entryChunkPosition

        if isNewDungeon {
            for x in 0..<dimensions.height {
                for y in 0..<dimensions.width {
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

    func getPlayerPosition() -> Point {
        Point(x: 0, y: 0)
    }

    func setLevelLayer(_ levelLayer: LevelLayer) {
        let playerPosition = getPlayerPosition()
        guard let level = getLevel(at: playerPosition, loadNeighbors: false) else {
            fatalError("should not be nil")
        }
        level.layer = levelLayer
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
        guard let level = getLevel(at: worldPosition) else {
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

        loadedLevels[levelPosition] = level
    }

    private func getLevel(
        at worldPosition: Point
    ) -> Level? {
        // The most basic behavior of getChunk is that it
        // 1. searches `loadedChunks` for the chunk at the given position and returns it
        // 2. tries to load a chunk with the same identifier as the given position
        // 3. If all fails, return nil.
        // This behavior can be abstracted into a Position to Chunk handler.

        let levelPosition = worldToLevelPosition(worldPosition)
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
        // In future, there may be multiple viewableChunkRegions due to multiplayer,
        // so we need to account for all of those.
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

    func getTile(at worldPosition: Point, loadNeighboringLevels: Bool) -> Tile? {
        guard let level = getLevel(at: worldPosition, loadNeighbors: loadNeighboringLevels) else {
            return nil
        }
        let positionWithinLevel = worldToPositionWithinLevel(worldPosition)

        return level.getTileAt(point: positionWithinLevel)
    }

    func setTile(_ tile: Tile, at worldPosition: Point) {
        guard let level = getLevel(at: worldPosition) else {
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
            entryChunkPosition: entryChunkPosition
        )
    }

    static func fromPersistable(_ persistableDungeon: PersistableDungeon) -> Dungeon {
        let dungeon = Dungeon(
            isNewDungeon: false,
            name: persistableDungeon.name,
            dimensions: persistableDungeon.dimensions,
            levelDimensions: persistableDungeon.levelDimensions,
            entryChunkPosition: persistableDungeon.entryChunkPosition
        )
        return dungeon
    }
}

enum DungeonKeyPathKeys: String, AbstractKeyPathIdentifierEnum {
    case name // TODO: placeholder
}

extension Dungeon: KeyPathExposable {
    static var exposedNumericKeyPathsMap: [DungeonKeyPathKeys: KeyPath<Dungeon, Int>] {
        [
            :
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
