//
//  StorageUtil.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 19/3/22.
//

import Foundation

struct StorageUtil {
    static let defaultFileStorageName = "TestDataFile1"
    static let preloadedLevelNames: [String] = []

    static func loadSavedLevels(fileName: String = defaultFileStorageName) -> [Level] {
        let jsonStorage = JSONStorage()
        let preloadedLevels = getPreloadedLevels()
        guard let gameStorage: GameStorage = try? jsonStorage.loadAndDecode(filename: fileName) else {
            globalLogger.info("Cannot find saved levels")
            return getPreloadedLevels()
        }
        var levels = gameStorage.levels
        levels.append(contentsOf: preloadedLevels)
        return levels
    }

    static func getPreloadedLevels() -> [Level] {
        []
    }

    static func updateJsonFileSavedLevels(dataFileName: String, savedLevels: [Level]) throws {
        let jsonStorage = JSONStorage()
        let levelsWithoutPreLoaded = savedLevels.filter({ !preloadedLevelNames.contains($0.name) })
        try jsonStorage.encodeAndSave(
            object: GameStorage(levels: levelsWithoutPreLoaded), filename: dataFileName
        )
    }

    static func getFileURL(from filename: String, with pathExtension: String) throws -> URL  {
        let storage = Storage(fileExtension: pathExtension)
        return try storage.getURL(filename: filename)
    }

    private static func createFileIfNotExists(at saveFileUrl: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: saveFileUrl.path) {
            fileManager.createFile(atPath: saveFileUrl.path, contents: nil)
        }
    }

    private static func getEncodedLevelData(levels: [Level]) throws -> Data {
        let store = GameStorage(levels: levels)
        let encoder = JSONEncoder()
        let levelsData = try encoder.encode(store)
        return levelsData
    }

    private static func saveFileExists(at url: URL) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: url.path)
    }
}
