import Foundation

class MetaLevel {
    var chunkDimensions: Int {
        ChunkNode.chunkDimensions
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
    var loadedChunks: [Point:ChunkNode] = [:]
    // TODO: As we add multiplayer feature, this will become a dictionary mapping players to chunk instead
    var currentChunk: ChunkNode?
    // TODO
    // var outlets: [Outlet] = []
    var dimensions: PositionedRectangle
    init(name: String, entryChunkPosition: Point, dimensions: PositionedRectangle) {
        self.name = name
        self.entryChunkPosition = entryChunkPosition
        self.dimensions = dimensions
    }
}

extension MetaLevel {
    func worldToChunkPosition(_ worldPosition: Point) -> Point {
        Point(x: worldPosition.x.flooredDiv(chunkDimensions), y: worldPosition.y.flooredDiv(chunkDimensions))
    }
    
    func getChunk(for worldPosition: Point) -> ChunkNode? {
        // The most basic behavior of getChunk is that it
        // 1. searches `loadedChunks` for the chunk at the given position and returns it
        // 2. tries to load a chunk with the same identifier as the given position
        // 3. If all fails, return nil.
        // This behavior can be abstracted into a Position to Chunk handler.
        
        let chunkPosition = worldToChunkPosition(worldPosition)
        
        if let foundChunk = loadedChunks[chunkPosition] {
            return foundChunk
        }
        
        let loadedChunk: ChunkNode? = chunkStorage.loadChunk(identifier: chunkPosition.dataString)
        loadedChunks[chunkPosition] = loadedChunk
        return loadedChunk
    }
}

// MARK: Persistence
extension MetaLevel {
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
        metaLevel.currentChunk = metaLevel.getChunk(for: metaLevel.entryChunkPosition)
        return metaLevel
    }
}



struct MetaTile {
    var metaEntity: MetaEntityType
}

extension MetaTile {
    func toPersistable() -> PersistableMetaTile {
        PersistableMetaTile(metaEntity: metaEntity)
    }
    
    static func fromPersistable(_ persistableMetaTile: PersistableMetaTile) -> MetaTile {
        MetaTile(metaEntity: persistableMetaTile.metaEntity)
    }
}

enum MetaEntityType {
    case blocking
    case nonBlocking
    case space
    case level
}

extension MetaEntityType: Codable {}
