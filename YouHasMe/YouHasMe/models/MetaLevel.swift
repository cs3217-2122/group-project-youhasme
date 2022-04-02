import Foundation
import Combine

protocol MetaLevelViewableDelegate: AnyObject {
    func getViewableRegion() -> PositionedRectangle
}

class MetaLevel {
    static let loadableChunkRadius: Int = 1
    static let defaultName: String = "MetaLevel1"
    weak var viewableDelegate: MetaLevelViewableDelegate?
    var chunkDimensions: Int {
        ChunkNode.chunkDimensions
    }
    var loadableChunkRadius: Int {
        MetaLevel.loadableChunkRadius
    }
    var metaLevelStorage = MetaLevelStorage()
    var chunkStorage: ChunkStorage {
        guard let storage = try? metaLevelStorage.getChunkStorage(for: name) else {
            fatalError("unexpected failure")
        }
        return storage
    }
    @Published private(set) var name: String
    var entryChunkPosition: Point = .zero
    var entryWorldPosition: Point = .zero
    var loadedChunks: [Point: ChunkNode] = [:]
    // TODO: As we add multiplayer feature, this will become a dictionary mapping players to chunk instead
    var currentChunk: ChunkNode?
    var dimensions: PositionedRectangle
    private var subscriptions: Set<AnyCancellable> = []

    convenience init() {
        self.init(
            name: MetaLevel.defaultName,
            dimensions: PositionedRectangle(
                rectangle: Rectangle(width: ChunkNode.chunkDimensions, height: ChunkNode.chunkDimensions),
                topLeft: .zero),
            entryChunkPosition: .zero
        )
    }

    init(name: String, dimensions: PositionedRectangle, entryChunkPosition: Point) {
        self.name = name
        self.dimensions = dimensions
        self.entryChunkPosition = entryChunkPosition
    }

    func renameLevel(to newName: String) {
        let oldName = name
        do {
            globalLogger.info("Attempting to rename from \(oldName) to \(newName)")
            try metaLevelStorage.renameMetaLevel(from: oldName, to: newName)
            name = newName
            try metaLevelStorage.saveMetaLevel(self)
        } catch {
            globalLogger.error("\(error)")
        }
    }
}

extension MetaLevel {
    func worldToChunkPosition(_ worldPosition: Point) -> Point {
        Point(x: worldPosition.x.flooredDiv(chunkDimensions), y: worldPosition.y.flooredDiv(chunkDimensions))
    }

    func worldToPositionWithinChunk(_ worldPosition: Point) -> Point {
        Point(x: worldPosition.x.modulo(chunkDimensions), y: worldPosition.y.modulo(chunkDimensions))
    }

    func worldRegionToChunkRegion(_ worldRegion: PositionedRectangle) -> PositionedRectangle {
        let chunkTopLeft = worldToChunkPosition(worldRegion.topLeft)
        let chunkBottomRight = worldToChunkPosition(worldRegion.bottomRight)
        return PositionedRectangle(
            rectangle: Rectangle(
                width: chunkBottomRight.x - chunkTopLeft.x,
                height: chunkBottomRight.y - chunkTopLeft.y
            ),
            topLeft: chunkTopLeft
        )
    }

    func getChunk(at worldPosition: Point, createIfNotExists: Bool = false) -> ChunkNode? {
        // The most basic behavior of getChunk is that it
        // 1. searches `loadedChunks` for the chunk at the given position and returns it
        // 2. tries to load a chunk with the same identifier as the given position
        // 3. If all fails, return nil.
        // This behavior can be abstracted into a Position to Chunk handler.

        let chunkPosition = worldToChunkPosition(worldPosition)
        print("\(worldPosition) \(chunkPosition) \(loadedChunks.count)")
        if let foundChunk = loadedChunks[chunkPosition] {
            return foundChunk
        }

        if let loadedChunk: ChunkNode = chunkStorage.loadChunk(identifier: chunkPosition.dataString) {
            print("Loaded chunk with position \(chunkPosition)")
            loadedChunks[chunkPosition] = loadedChunk
            return loadedChunk
        }

        guard createIfNotExists else {
            return nil
        }

        print("Creating new with position \(chunkPosition)")
        let chunkNode = ChunkNode(identifier: chunkPosition)

        do {
            try chunkStorage.saveChunk(chunkNode)
        } catch {
            fatalError("unexpected save failure")
        }

        loadedChunks[chunkPosition] = chunkNode
        return chunkNode
    }

    func unloadChunkNodes() {
        guard let delegate = viewableDelegate else {
            return
        }
        let viewableWorldRegion = delegate.getViewableRegion()
        let viewableChunkRegion = worldRegionToChunkRegion(viewableWorldRegion)
        let loadableChunkRegion = viewableChunkRegion.expandInAllDirections(by: loadableChunkRadius)
        // Unload all chunks that are very far away from the viewable region
        // In future, there may be multiple viewableChunkRegions due to multiplayer,
        // so we need to account for all of those.
        for (position, loadedChunk) in loadedChunks {
            guard !loadableChunkRegion.contains(point: position) else {
                continue
            }

            do {
                try chunkStorage.saveChunk(loadedChunk)
            } catch {
                fatalError("unexpected failure")
            }
            loadedChunks[position] = nil
        }
    }

    func getTile(at worldPosition: Point, createChunkIfNotExists: Bool = false) -> MetaTile? {
        guard let chunk = getChunk(at: worldPosition, createIfNotExists: createChunkIfNotExists) else {
            return nil
        }
        let positionWithinChunk = worldToPositionWithinChunk(worldPosition)
        return chunk.getTile(at: positionWithinChunk)
    }

    func setTile(_ tile: MetaTile, at worldPosition: Point) {
        guard let chunk = getChunk(at: worldPosition) else {
            return
        }
        let positionWithinChunk = worldToPositionWithinChunk(worldPosition)
        chunk.setTile(tile, at: positionWithinChunk)
    }
}

extension MetaLevel: Equatable {
    static func == (lhs: MetaLevel, rhs: MetaLevel) -> Bool {
        lhs === rhs
    }
}

// MARK: Persistence
extension MetaLevel {
    func saveLoadedChunks() throws {
        for loadedChunk in loadedChunks.values {
            try chunkStorage.saveChunk(loadedChunk)
        }
    }

    func toPersistable() -> PersistableMetaLevel {
        PersistableMetaLevel(
            name: name,
            entryChunkPosition: entryChunkPosition,
            dimensions: dimensions
        )
    }

    static func fromPersistable(_ persistableMetaLevel: PersistableMetaLevel) -> MetaLevel {
        let metaLevel = MetaLevel(
            name: persistableMetaLevel.name,
            dimensions: persistableMetaLevel.dimensions,
            entryChunkPosition: persistableMetaLevel.entryChunkPosition
        )
        metaLevel.currentChunk = metaLevel.getChunk(at: metaLevel.entryChunkPosition)
        return metaLevel
    }
}

extension MetaLevel: KeyPathExposable {
    static var exposedNumericKeyPathsMap: [String: KeyPath<MetaLevel, Int>] {
        [
            "Name length": \.name.count
        ]
    }

    func evaluate(given keyPath: NamedKeyPath<MetaLevel, Int>) -> Int {
        self[keyPath: keyPath.keyPath]
    }
}

class MetaTile {
    @Published var metaEntities: [MetaEntityType] = []

    init() {}

    init(metaEntities: [MetaEntityType]) {
        self.metaEntities = metaEntities
    }
}

// MARK: Persistence
extension MetaTile {
    func toPersistable() -> PersistableMetaTile {
        PersistableMetaTile(metaEntities: metaEntities.map { $0.toPersistable() })
    }

    static func fromPersistable(_ persistableMetaTile: PersistableMetaTile) -> MetaTile {
        let metaEntities = persistableMetaTile.metaEntities.map(MetaEntityType.fromPersistable(_:))
        return MetaTile(metaEntities: metaEntities)
    }
}

enum MetaEntityType {
    case blocking
    case nonBlocking
    case space
    case level(levelLoadable: Loadable? = nil, unlockCondition: Condition? = nil)
    case travel(metaLevelLoadable: Loadable? = nil, unlockCondition: Condition? = nil)
    // TODO: Perhaps the message can be associated with a user
    case message(text: String? = nil)

    func getSelfWithDefaultValues() -> MetaEntityType {
        switch self {
        case .blocking:
            return .blocking
        case .nonBlocking:
            return .nonBlocking
        case .space:
            return .space
        case .level:
            return .level()
        case .travel:
            return .travel()
        case .message:
            return .message()
        }
    }
}

extension MetaEntityType: CaseIterable {
    static var allCases: [MetaEntityType] {
        [.blocking, .nonBlocking, .space, .level(), .travel(), .message()]
    }
}

extension MetaEntityType: CustomStringConvertible {
    var description: String {
        switch self {
        case .blocking:
            return "Blocking"
        case .nonBlocking:
            return "Nonblocking"
        case .space:
            return "Empty space"
        case .level(let levelLoadable, let unlockCondition):
            return "Level"
        case .travel(let metaLevelLoadable, let unlockCondition):
            return "Travel point"
        case .message(let text):
            return "Message"
        }
    }
}

extension MetaEntityType {
    func toPersistable() -> PersistableMetaEntityType {
        switch self {
        case .blocking:
            return .blocking
        case .nonBlocking:
            return .nonBlocking
        case .space:
            return .space
        case .level(let levelLoadable, let unlockCondition):
            return .level(
                levelLoadable: levelLoadable,
                unlockCondition: unlockCondition?.toPersistable()
            )
        case .travel(let metaLevelLoadable, let unlockCondition):
            return .travel(metaLevelLoadable: metaLevelLoadable, unlockCondition: unlockCondition?.toPersistable())
        case .message(let text):
            return .message(text: text)
        }
    }

    static func fromPersistable(_ persistableMetaEntity: PersistableMetaEntityType) -> MetaEntityType {
        switch persistableMetaEntity {
        case .blocking:
            return .blocking
        case .nonBlocking:
            return .nonBlocking
        case .space:
            return .space
        case .level(let levelLoadable, let unlockCondition):
            guard let unlockCondition = unlockCondition else {
                return .level(levelLoadable: levelLoadable, unlockCondition: nil)
            }
            return .level(levelLoadable: levelLoadable, unlockCondition: Condition.fromPersistable(unlockCondition))
        case .travel(let metaLevelLoadable, let unlockCondition):
            guard let unlockCondition = unlockCondition else {
                return .travel(metaLevelLoadable: metaLevelLoadable, unlockCondition: nil)
            }
            return .travel(metaLevelLoadable: metaLevelLoadable, unlockCondition: Condition.fromPersistable(unlockCondition))
        case .message(let text):
            return .message(text: text)
        }
    }
}

extension MetaEntityType: Hashable {}
