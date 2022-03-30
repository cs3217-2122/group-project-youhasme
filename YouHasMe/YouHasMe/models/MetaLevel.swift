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
    var chunkStorage: ChunkStorage {
        guard let storage = try? MetaLevelStorage().getChunkStorage(for: name) else {
            fatalError("unexpected failure")
        }
        return storage
    }
    var name: String
    var entryChunkPosition: Point = .zero
    var entryWorldPosition: Point = .zero
    var loadedChunks: [Point: ChunkNode] = [:]
    // TODO: As we add multiplayer feature, this will become a dictionary mapping players to chunk instead
    var currentChunk: ChunkNode?
    var dimensions: PositionedRectangle

    init() {
        self.name = MetaLevel.defaultName
        self.dimensions = PositionedRectangle(
            rectangle: Rectangle(width: ChunkNode.chunkDimensions, height: ChunkNode.chunkDimensions),
            topLeft: .zero
        )
    }

    init(name: String, entryChunkPosition: Point, dimensions: PositionedRectangle) {
        self.name = name
        self.entryChunkPosition = entryChunkPosition
        self.dimensions = dimensions
    }

    func hydrate(with persistableMetaLevel: PersistableMetaLevel) {
        // TODO: This function may not be necessary
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
//        print("\(worldPosition) \(chunkPosition) \(loadedChunks.count)")
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
            entryChunkPosition: persistableMetaLevel.entryChunkPosition,
            dimensions: persistableMetaLevel.dimensions
        )
        metaLevel.currentChunk = metaLevel.getChunk(at: metaLevel.entryChunkPosition)
        return metaLevel
    }
}

class MetaTile {
    @Published var metaEntities: [MetaEntityType] = []
    init() {}

    init(metaEntities: [MetaEntityType]) {
        self.metaEntities = metaEntities
    }
}

extension MetaTile {
    func getLevelURL() -> URL? {
        for metaEntity in metaEntities {
            if case .level(levelURL: let levelURL, unlockCondition: _) = metaEntity {
                return levelURL
            }
        }

        return nil
    }
}

// MARK: Persistence
extension MetaTile {
    func toPersistable() -> PersistableMetaTile {
        PersistableMetaTile(metaEntities: metaEntities)
    }

    static func fromPersistable(_ persistableMetaTile: PersistableMetaTile) -> MetaTile {
        MetaTile(metaEntities: persistableMetaTile.metaEntities)
    }
}

enum MetaEntityType: CaseIterable {
    static var allCases: [MetaEntityType] {
        [.blocking, .nonBlocking, .space, .level(), .travel(), .message()]
    }

    case blocking
    case nonBlocking
    case space
    case level(levelURL: URL? = nil, unlockCondition: Condition? = nil)
    case travel(metaLevelURL: URL? = nil, unlockCondition: Condition? = nil)
    // TODO: Perhaps the message can be associated with a user
    case message(text: String? = nil)

    func getSelfWithDefaultValues() -> MetaEntityType {
        switch self {
        case .blocking, .nonBlocking, .space:
            return self
        case .level:
            return .level()
        case .travel:
            return .travel()
        case .message:
            return .message()
        }
    }
}

extension MetaEntityType: Codable {}

extension MetaEntityType: RawRepresentable {
    typealias RawValue = Int
    init?(rawValue: RawValue) {
        guard rawValue < MetaEntityType.allCases.count else {
            return nil
        }
        self = MetaEntityType.allCases[rawValue]
    }

    var rawValue: RawValue {
        guard let firstIndex = MetaEntityType.allCases.firstIndex(of: self.getSelfWithDefaultValues()) else {
            fatalError("should not be nil")
        }

        return firstIndex
    }
}

extension MetaEntityType: Hashable {}
