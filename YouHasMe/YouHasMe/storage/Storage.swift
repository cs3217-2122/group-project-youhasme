//
//  Storage.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 22/3/22.
//

import Foundation

/// Handles all local storage operations like reading, writing to a file.
///
/// Example:
/// 1. Suppose a user wants to conduct file operations with image files, say of format `png`
/// ```
/// var pngStorage = Storage(fileExtension: "png")
/// ```
class Storage {
    private static let defaultDirectoryName = "YouHasMe"
    /// The file extension associated with this storage object, so that all files read and written
    /// are appended with this extension.
    let fileExtension: String

    init(fileExtension: String) {
        self.fileExtension = fileExtension
    }
    
    func getDefaultDirectory() throws -> URL {
        let url = try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(Storage.defaultDirectoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
    
    func getURL(filename: String) throws -> URL {
        try getDefaultDirectory()
            .appendingPathComponent(filename)
            .appendingPathExtension(fileExtension)
    }

    func save(data: Data, to file: URL) throws {
        try data.write(to: file)
    }

    func load(from file: URL) throws -> Data {
        try Data(contentsOf: file)
    }

    func delete(file: URL) throws {
        try FileManager.default.removeItem(at: file)
    }

    func getAllFiles(in directory: URL) -> (urls: [URL], filenames: [String]) {
        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: directory, includingPropertiesForKeys: nil, options: [])
            let jsonUrls = urls.filter({ $0.pathExtension == fileExtension })
            let filenames = jsonUrls.map { $0.deletingPathExtension().lastPathComponent }
            return (jsonUrls, filenames)
        } catch {
            globalLogger.error(error.localizedDescription)
        }
        return ([], [])
    }
}

extension Storage {
    func save(data: Data, filename: String) throws {
        try save(data: data, to: getURL(filename: filename))
    }

    func load(filename: String) throws -> Data {
        try load(from: getURL(filename: filename))
    }

    func delete(filename: String) throws {
        try delete(file: getURL(filename: filename))
    }

    func getAllFiles() -> (urls: [URL], filenames: [String]) {
        do {
            return try getAllFiles(in: getDefaultDirectory())
        } catch {
            globalLogger.error(error.localizedDescription)
        }
        return ([], [])
    }
}

/// A specialization of the `Storage` class used with interacting with json files. In addition to the base class's
/// read and write operations, `JSONStorage` also handles encoding to json and decoding from json.
class JSONStorage: Storage {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init() {
        super.init(fileExtension: "json")
    }

    func encode<T: Encodable>(object: T) throws -> Data {
        let result = try encoder.encode(object)
        return result
    }

    func encodeAndSave<T: Encodable>(object: T, to file: URL) throws {
        try save(data: encode(object: object), to: file)
    }

    func decode<T: Decodable>(data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }

    func loadAndDecode<T: Decodable>(from file: URL) throws -> T {
        try decode(data: load(from: file))
    }

}

extension JSONStorage {
    func encodeAndSave<T: Encodable>(object: T, filename: String) throws {
        try encodeAndSave(object: object, to: getURL(filename: filename))
    }

    func loadAndDecode<T: Decodable>(filename: String) throws -> T {
        try loadAndDecode(from: getURL(filename: filename))
    }
}

class LevelStorage: JSONStorage {
    static let levelDirectoryName: String = "Levels"
    static let defaultFileStorageName = "TestDataFile1"
    static let preloadedLevelNames: [String] = []
    
    override func getDefaultDirectory() throws -> URL {
        try super.getDefaultDirectory().appendingPathComponent(LevelStorage.levelDirectoryName)
    }
    
    func loadSavedLevels(fileName: String = LevelStorage.defaultFileStorageName) -> [Level] {
        let preloadedLevels = getPreloadedLevels()
        guard let gameStorage: GameStorage = try? loadAndDecode(filename: fileName) else {
            globalLogger.info("Cannot find saved levels")
            return getPreloadedLevels()
        }
        var levels = gameStorage.levels
        levels.append(contentsOf: preloadedLevels)
        return levels
    }
    
    func getPreloadedLevels() -> [Level] {
        []
    }
    
    func updateJsonFileSavedLevels(dataFileName: String, savedLevels: [Level]) throws {
        let levelsWithoutPreLoaded = savedLevels.filter({ !LevelStorage.preloadedLevelNames.contains($0.name) })
        try encodeAndSave(
            object: GameStorage(levels: levelsWithoutPreLoaded), filename: dataFileName
        )
    }
}

class MetaLevelStorage: JSONStorage {
    static let metaLevelDirectoryName: String = "MetaLevels"
    
    override func getDefaultDirectory() throws -> URL {
        try super.getDefaultDirectory().appendingPathComponent(MetaLevelStorage.metaLevelDirectoryName)
    }
    
    func loadMetaLevel(name: String) throws -> PersistableMetaLevel {
        try loadAndDecode(filename: name)
    }
    
    func getChunkStorage(for metaLevelName: String) throws -> ChunkStorage {
        try ChunkStorage(metaLevelDirectory: getDefaultDirectory().appendingPathComponent(metaLevelName))
    }
}

class ChunkStorage: JSONStorage {
    static let chunkStorageDirectoryName: String = "Chunks"
    var metaLevelDirectory: URL
    
    init(metaLevelDirectory: URL) {
        self.metaLevelDirectory = metaLevelDirectory
    }
    
    override func getDefaultDirectory() throws -> URL {
        metaLevelDirectory.appendingPathComponent(ChunkStorage.chunkStorageDirectoryName)
    }
    
    func loadChunk(identifier: String) -> PersistableChunkNode? {
        try? loadAndDecode(filename: identifier)
    }
    
    func loadChunk(identifier: String) -> ChunkNode? {
        guard let persistableChunk: PersistableChunkNode = loadChunk(identifier: identifier) else {
            return nil
        }
        return ChunkNode.fromPersistable(persistableChunk)
    }
}