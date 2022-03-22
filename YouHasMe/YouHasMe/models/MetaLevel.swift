import Foundation

struct MetaLevel {
    var name: String
    var entryChunkPosition: Point = .zero
    var currentChunk: ChunkNode
    // TODO
    // var outlets: [Outlet] = []
    var dimensions: PositionedRectangle
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
        guard let chunkStorage = try? MetaLevelStorage().getChunkStorage(for: persistableMetaLevel.name) else {
            fatalError("should not be nil")
        }
        
        guard let entryChunk = try? chunkStorage.loadChunk(identifier: persistableMetaLevel.entryChunkPosition.dataString) else {
            fatalError("should not be nil")
        }
        
        return MetaLevel(
            name: persistableMetaLevel.name,
            entryChunkPosition: persistableMetaLevel.entryChunkPosition,
            currentChunk: entryChunk,
            dimensions: persistableMetaLevel.dimensions
        )
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
