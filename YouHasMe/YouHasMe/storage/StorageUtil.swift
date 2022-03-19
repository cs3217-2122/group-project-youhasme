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

        let url = getFileURL(from: fileName, with: "json")
        let preloadedLevels = getPreloadedLevels()

        if !saveFileExists(at: url) {
            return preloadedLevels
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let storage = try decoder.decode(GameStorage.self, from: data)
            var updatedLevels = storage.levels
            updatedLevels.append(contentsOf: preloadedLevels)
            return updatedLevels
        } catch {
            print("error loading levels from json: \(error)")
        }

        return []
    }

    static func getPreloadedLevels() -> [Level] {
        return []
    }

    static func updateJsonFileSavedLevels(dataFileName: String, savedLevels: [Level]) throws {
        let levelsWithoutPreLoaded = savedLevels.filter({ !preloadedLevelNames.contains($0.name) })
        let levelsData = try getEncodedLevelData(levels: levelsWithoutPreLoaded)

        let saveFileUrl = getFileURL(from: dataFileName, with: "json")
        createFileIfNotExists(at: saveFileUrl)

        try levelsData.write(to: saveFileUrl)
    }

    static func getFileURL(from name: String, with pathExtension: String) -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(name).appendingPathExtension(pathExtension)
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
